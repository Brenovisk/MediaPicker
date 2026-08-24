# GitHub roadmap automation

`sync_github_roadmap.py` reads `Docs/Roadmapv0.0.1.md`, creates or updates its
milestones and issues, assigns every issue to its milestone, and inserts the
issues into a GitHub Projects v2 project.

The script is idempotent. It identifies synced issues with a hidden marker in
their body and falls back to an exact title match on the first run. Roadmap
dependency references are rewritten to the actual GitHub issue numbers, so the
repository does not need to start with an empty issue list.

## Usage

Preview and validate the roadmap without making network requests:

```sh
python3 Scripts/SyncGithubRoadmap/sync_github_roadmap.py
```

Apply it to the project owned by the repository owner:

```sh
export GH_TOKEN="your-token"
python3 Scripts/SyncGithubRoadmap/sync_github_roadmap.py --project-number 1 --apply
```

Use `--repo OWNER/REPO` when the Git remote cannot be inferred, and
`--project-owner LOGIN` when the project belongs to a different user or
organization. To create milestones and issues without a project, explicitly use
`--no-project --apply`.

The token must be able to write issues and milestones in the repository and to
write the selected Projects v2 project. For a fine-grained personal access
token, grant repository Issues read/write access and Projects read/write access.
