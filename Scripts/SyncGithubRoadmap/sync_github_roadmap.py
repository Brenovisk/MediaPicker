#!/usr/bin/env python3
"""Create/update GitHub milestones and issues from the MediaPicker roadmap.

The script uses GitHub's REST and GraphQL APIs directly and requires only Python's
standard library. It is a dry run unless --apply is supplied.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
import urllib.error
import urllib.parse
import urllib.request
from dataclasses import dataclass
from pathlib import Path
from typing import Any


ISSUE_HEADING = re.compile(r"^### Issue #(\d+) — (.+?)\s*$", re.MULTILINE)
MILESTONE_HEADING = re.compile(r"^# (M\d+) — (.+?)\s*$", re.MULTILINE)
REFERENCE = re.compile(r"(?<![\w/])#(\d+)\b")
ISSUE_MARKER = "<!-- mediapicker-roadmap-issue:{number} -->"


@dataclass(frozen=True)
class RoadmapIssue:
    roadmap_number: int
    title: str
    body: str
    milestone_title: str


@dataclass(frozen=True)
class RoadmapMilestone:
    code: str
    title: str
    description: str
    issues: tuple[RoadmapIssue, ...]


def section_text(text: str, heading: str) -> str:
    match = re.search(
        rf"^## {re.escape(heading)}\s*$\n(.*?)(?=^## |^### Issue|\Z)",
        text,
        flags=re.MULTILINE | re.DOTALL,
    )
    return match.group(1).strip() if match else ""


def parse_roadmap(path: Path) -> list[RoadmapMilestone]:
    text = path.read_text(encoding="utf-8")
    milestones: list[RoadmapMilestone] = []
    matches = list(MILESTONE_HEADING.finditer(text))

    for index, match in enumerate(matches):
        block_end = matches[index + 1].start() if index + 1 < len(matches) else len(text)
        block = text[match.end() : block_end]
        issue_matches = list(ISSUE_HEADING.finditer(block))
        if not issue_matches:
            continue

        preamble = block[: issue_matches[0].start()]
        goal = section_text(preamble, "Milestone Goal")
        deliverable = section_text(preamble, "Milestone Deliverable")
        description_parts = []
        if goal:
            description_parts.append(f"Goal: {goal}")
        if deliverable:
            description_parts.append(f"Deliverable: {deliverable}")

        milestone_title = f"{match.group(1)} — {match.group(2).strip()}"
        issues: list[RoadmapIssue] = []
        for issue_index, issue_match in enumerate(issue_matches):
            if issue_index + 1 < len(issue_matches):
                issue_end = issue_matches[issue_index + 1].start()
            else:
                following_section = re.search(r"^## ", block[issue_match.end() :], re.MULTILINE)
                issue_end = (
                    issue_match.end() + following_section.start()
                    if following_section
                    else len(block)
                )
            body = block[issue_match.end() : issue_end].strip()
            issues.append(
                RoadmapIssue(
                    roadmap_number=int(issue_match.group(1)),
                    title=issue_match.group(2).strip(),
                    body=body,
                    milestone_title=milestone_title,
                )
            )

        milestones.append(
            RoadmapMilestone(
                code=match.group(1),
                title=milestone_title,
                description="\n\n".join(description_parts),
                issues=tuple(issues),
            )
        )

    issue_numbers = [issue.roadmap_number for milestone in milestones for issue in milestone.issues]
    if not milestones:
        raise ValueError("No milestones were found in the roadmap")
    if issue_numbers != list(range(1, len(issue_numbers) + 1)):
        raise ValueError(f"Roadmap issue numbers must be contiguous from 1; found {issue_numbers}")
    return milestones


def infer_repository() -> str:
    try:
        remote = subprocess.run(
            ["git", "config", "--get", "remote.origin.url"],
            check=True,
            capture_output=True,
            text=True,
        ).stdout.strip()
    except (OSError, subprocess.CalledProcessError) as error:
        raise ValueError("Cannot infer repository; pass --repo OWNER/REPO") from error

    match = re.search(r"github\.com[/:]([^/]+)/([^/]+?)(?:\.git)?$", remote)
    if not match:
        raise ValueError(f"Cannot infer a GitHub repository from origin: {remote}")
    return f"{match.group(1)}/{match.group(2)}"


class GitHubClient:
    def __init__(self, token: str) -> None:
        self.token = token

    def request(
        self,
        method: str,
        url: str,
        payload: dict[str, Any] | None = None,
    ) -> tuple[Any, dict[str, str]]:
        data = json.dumps(payload).encode() if payload is not None else None
        request = urllib.request.Request(
            url,
            data=data,
            method=method,
            headers={
                "Accept": "application/vnd.github+json",
                "Authorization": f"Bearer {self.token}",
                "Content-Type": "application/json",
                "User-Agent": "MediaPicker-roadmap-sync",
                "X-GitHub-Api-Version": "2026-03-10",
            },
        )
        try:
            with urllib.request.urlopen(request) as response:
                raw = response.read()
                result = json.loads(raw) if raw else None
                return result, dict(response.headers.items())
        except urllib.error.HTTPError as error:
            details = error.read().decode("utf-8", errors="replace")
            try:
                message = json.loads(details).get("message", details)
            except json.JSONDecodeError:
                message = details
            raise RuntimeError(f"GitHub API {method} {url} failed ({error.code}): {message}") from error

    def rest(
        self,
        method: str,
        path: str,
        payload: dict[str, Any] | None = None,
    ) -> Any:
        result, _ = self.request(method, f"https://api.github.com{path}", payload)
        return result

    def paginate(self, path: str) -> list[dict[str, Any]]:
        separator = "&" if "?" in path else "?"
        url: str | None = f"https://api.github.com{path}{separator}per_page=100"
        results: list[dict[str, Any]] = []
        while url:
            page, headers = self.request("GET", url)
            results.extend(page)
            url = next_link(headers.get("Link", ""))
        return results

    def graphql(self, query: str, variables: dict[str, Any]) -> dict[str, Any]:
        result = self.rest("POST", "/graphql", {"query": query, "variables": variables})
        if result.get("errors"):
            messages = "; ".join(error.get("message", str(error)) for error in result["errors"])
            raise RuntimeError(f"GitHub GraphQL request failed: {messages}")
        return result["data"]


def next_link(header: str) -> str | None:
    for part in header.split(","):
        match = re.match(r'\s*<([^>]+)>;\s*rel="([^"]+)"', part)
        if match and match.group(2) == "next":
            return match.group(1)
    return None


def render_issue_body(issue: RoadmapIssue, number_map: dict[int, int]) -> str:
    def replace_reference(match: re.Match[str]) -> str:
        roadmap_number = int(match.group(1))
        return f"#{number_map.get(roadmap_number, roadmap_number)}"

    body = REFERENCE.sub(replace_reference, issue.body)
    marker = ISSUE_MARKER.format(number=issue.roadmap_number)
    return f"{body}\n\n---\n{marker}\n_Synced from `Docs/Roadmapv0.0.1.md`._"


def find_existing_issue(
    roadmap_issue: RoadmapIssue,
    remote_issues: list[dict[str, Any]],
) -> dict[str, Any] | None:
    marker = ISSUE_MARKER.format(number=roadmap_issue.roadmap_number)
    marked = [item for item in remote_issues if marker in (item.get("body") or "")]
    if len(marked) > 1:
        raise RuntimeError(f"Multiple GitHub issues contain roadmap marker #{roadmap_issue.roadmap_number}")
    if marked:
        return marked[0]

    exact = [item for item in remote_issues if item.get("title") == roadmap_issue.title]
    if len(exact) > 1:
        raise RuntimeError(f"Multiple GitHub issues have title {roadmap_issue.title!r}")
    return exact[0] if exact else None


PROJECT_QUERY = """
query($login: String!, $number: Int!, $cursor: String) {
  user(login: $login) {
    projectV2(number: $number) {
      id title
      items(first: 100, after: $cursor) {
        pageInfo { hasNextPage endCursor }
        nodes { content { ... on Issue { id number repository { nameWithOwner } } } }
      }
    }
  }
  organization(login: $login) {
    projectV2(number: $number) {
      id title
      items(first: 100, after: $cursor) {
        pageInfo { hasNextPage endCursor }
        nodes { content { ... on Issue { id number repository { nameWithOwner } } } }
      }
    }
  }
}
"""


def load_project(client: GitHubClient, owner: str, number: int) -> tuple[str, str, set[str]]:
    cursor: str | None = None
    project_id = ""
    project_title = ""
    issue_node_ids: set[str] = set()
    while True:
        data = client.graphql(PROJECT_QUERY, {"login": owner, "number": number, "cursor": cursor})
        project = (data.get("user") or {}).get("projectV2") or (
            data.get("organization") or {}
        ).get("projectV2")
        if not project:
            raise RuntimeError(f"Project {owner}/{number} was not found or is not accessible")
        project_id = project["id"]
        project_title = project["title"]
        items = project["items"]
        for node in items["nodes"]:
            content = node.get("content") or {}
            if content.get("id"):
                issue_node_ids.add(content["id"])
        if not items["pageInfo"]["hasNextPage"]:
            break
        cursor = items["pageInfo"]["endCursor"]
    return project_id, project_title, issue_node_ids


def add_to_project(client: GitHubClient, project_id: str, content_id: str) -> None:
    client.graphql(
        """
        mutation($project: ID!, $content: ID!) {
          addProjectV2ItemById(input: {projectId: $project, contentId: $content}) { item { id } }
        }
        """,
        {"project": project_id, "content": content_id},
    )


def sync(args: argparse.Namespace, milestones: list[RoadmapMilestone]) -> None:
    issue_count = sum(len(milestone.issues) for milestone in milestones)
    print(f"Parsed {len(milestones)} milestones and {issue_count} issues from {args.roadmap}")
    for milestone in milestones:
        print(f"  {milestone.title}: {len(milestone.issues)} issues")

    if not args.apply:
        print("\nDry run only. Re-run with --apply and --project-number NUMBER to sync GitHub.")
        return

    token = os.environ.get("GH_TOKEN") or os.environ.get("GITHUB_TOKEN")
    if not token:
        raise ValueError("Set GH_TOKEN or GITHUB_TOKEN before using --apply")
    if args.project_number is None and not args.no_project:
        raise ValueError("Pass --project-number NUMBER, or explicitly use --no-project")

    repository = args.repo or infer_repository()
    if not re.fullmatch(r"[^/]+/[^/]+", repository):
        raise ValueError("--repo must have the form OWNER/REPO")
    repo_owner = repository.split("/", 1)[0]
    project_owner = args.project_owner or repo_owner
    encoded_repo = "/".join(urllib.parse.quote(part, safe="") for part in repository.split("/"))
    client = GitHubClient(token)

    remote_milestones = client.paginate(f"/repos/{encoded_repo}/milestones?state=all")
    milestones_by_title = {item["title"]: item for item in remote_milestones}
    milestone_numbers: dict[str, int] = {}
    for milestone in milestones:
        existing = milestones_by_title.get(milestone.title)
        payload = {"title": milestone.title, "description": milestone.description}
        if existing:
            updated = client.rest(
                "PATCH", f"/repos/{encoded_repo}/milestones/{existing['number']}", payload
            )
            action = "Updated"
        else:
            payload["state"] = "open"
            updated = client.rest("POST", f"/repos/{encoded_repo}/milestones", payload)
            action = "Created"
        milestone_numbers[milestone.title] = updated["number"]
        print(f"{action} milestone: {milestone.title}")

    remote_issues = [
        item
        for item in client.paginate(f"/repos/{encoded_repo}/issues?state=all")
        if "pull_request" not in item
    ]
    number_map: dict[int, int] = {}
    issue_records: list[dict[str, Any]] = []
    for milestone in milestones:
        for roadmap_issue in milestone.issues:
            existing = find_existing_issue(roadmap_issue, remote_issues)
            if existing:
                number_map[roadmap_issue.roadmap_number] = existing["number"]
                body = render_issue_body(roadmap_issue, number_map)
                payload = {
                    "title": roadmap_issue.title,
                    "body": body,
                    "milestone": milestone_numbers[roadmap_issue.milestone_title],
                }
                record = client.rest(
                    "PATCH", f"/repos/{encoded_repo}/issues/{existing['number']}", payload
                )
                action = "Updated"
            else:
                body = render_issue_body(roadmap_issue, number_map)
                payload = {
                    "title": roadmap_issue.title,
                    "body": body,
                    "milestone": milestone_numbers[roadmap_issue.milestone_title],
                }
                record = client.rest("POST", f"/repos/{encoded_repo}/issues", payload)
                number_map[roadmap_issue.roadmap_number] = record["number"]
                remote_issues.append(record)
                action = "Created"
            issue_records.append(record)
            print(f"{action} issue #{record['number']}: {record['title']}")

    # Re-render once all actual numbers are known, which also fixes forward references.
    for milestone in milestones:
        for roadmap_issue in milestone.issues:
            actual_number = number_map[roadmap_issue.roadmap_number]
            client.rest(
                "PATCH",
                f"/repos/{encoded_repo}/issues/{actual_number}",
                {"body": render_issue_body(roadmap_issue, number_map)},
            )

    if args.no_project:
        print(f"\nSynced {len(issue_records)} issues to {repository}; project insertion skipped.")
        return

    project_id, project_title, project_issue_ids = load_project(
        client, project_owner, args.project_number
    )
    added = 0
    for record in issue_records:
        if record["node_id"] in project_issue_ids:
            continue
        add_to_project(client, project_id, record["node_id"])
        project_issue_ids.add(record["node_id"])
        added += 1
    print(
        f"\nSynced {len(issue_records)} issues to {repository}; "
        f"added {added} items to project {project_owner}/{args.project_number} ({project_title})."
    )


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Synchronize roadmap milestones and issues with GitHub Projects v2."
    )
    parser.add_argument(
        "--roadmap",
        type=Path,
        default=Path(__file__).resolve().parents[2] / "Docs" / "Roadmapv0.0.1.md",
        help="Roadmap Markdown path (default: repository Docs/Roadmapv0.0.1.md)",
    )
    parser.add_argument("--repo", help="GitHub repository as OWNER/REPO (default: infer origin)")
    parser.add_argument("--project-number", type=int, help="GitHub Projects v2 number")
    parser.add_argument(
        "--project-owner", help="Project user/organization login (default: repository owner)"
    )
    parser.add_argument(
        "--no-project",
        action="store_true",
        help="Create/update repository milestones and issues without adding project items",
    )
    parser.add_argument(
        "--apply",
        action="store_true",
        help="Perform GitHub writes (without this flag the script only validates and previews)",
    )
    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    if args.project_number is not None and args.no_project:
        parser.error("--project-number and --no-project cannot be used together")
    try:
        milestones = parse_roadmap(args.roadmap)
        sync(args, milestones)
    except (OSError, RuntimeError, ValueError) as error:
        print(f"error: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
