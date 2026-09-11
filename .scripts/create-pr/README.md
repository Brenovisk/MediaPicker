# Create Pull Request

Runs SwiftLint, validates the package, synchronizes the current branch,
generates a Pull Request title and description with an AI provider, and creates
the Pull Request through the GitHub CLI.

The generated description follows `.github/PULL_REQUEST_TEMPLATE.md` and is
shown for review before the Pull Request is created.

## Requirements

- Bash
- Swift
- Git
- GitHub CLI (`gh`), authenticated with access to the repository
- An `origin` remote
- One installed and authenticated AI CLI:
  - Claude Code (`claude`)
  - Codex (`codex`)
  - Gemini (`gemini`)

Authenticate GitHub CLI when necessary:

```sh
gh auth login
```

## Install commands

Install the repository command launchers once after cloning:

```sh
./.scripts/install-commands.sh
```

This creates `create-commit` and `create-pr` links in
`${XDG_BIN_HOME:-$HOME/.local/bin}`. The installer does not replace an existing
file or a command installed from another location.

## Setup

Run it from the repository root with a clean working tree. All intended changes
must already be committed.

## Usage

Choose the AI provider interactively:

```sh
create-pr
```

Or provide it as the first argument:

```sh
create-pr codex
create-pr claude
create-pr gemini
```

To create a Pull Request without requiring or linking a GitHub issue:

```sh
create-pr --no-issue
create-pr codex --no-issue
```

The `--no-issue` option allows a branch without an issue number, skips issue
validation, and leaves the Related Issues section empty.

## Branch targeting

The base branch is selected automatically:

| Current branch | Pull Request base |
| --- | --- |
| `develop` | `master` |
| Any other non-`master` branch | `develop` |
| `master` | Not allowed |

This supports feature branches merging into `develop`, followed by release Pull
Requests from `develop` into `master`.

Unless `--no-issue` is used, branches targeting `develop` must include the
related issue number immediately after the first slash:

```text
feat/7-media-type
fix/14-camera-permission
chore/5-contribution-conventions
```

The script validates that the issue exists and writes a deterministic reference
in the Pull Request body:

```text
Related issue: #7
```

Release Pull Requests from `develop` to `master` and Pull Requests created with
`--no-issue` do not require an issue number.

## What the script does

1. Runs the pinned SwiftLint configuration before any Pull Request preparation.
2. Runs `swift test` and stops if linting, compilation, or any test fails.
3. Validates Git, GitHub CLI authentication, and the selected AI CLI.
4. Resolves the current branch, base branch, and optional related issue number.
5. Validates the issue for branches targeting `develop`, unless `--no-issue`
   is used.
6. Requires a clean working tree and an `origin` remote.
7. Fetches the base branch and verifies that the current branch has commits to
   propose.
8. Pushes the current branch, configuring its upstream when necessary.
9. Stops if an open Pull Request already exists for the same branch pair.
10. Collects commits, changed files, statistics, the Git diff, and the repository
   Pull Request template.
11. Generates and validates a title and description with the selected AI.
12. Inserts `Related issue: #N` when an issue is present.
13. Shows the complete proposal and asks for confirmation.
14. Creates the Pull Request with `gh pr create` after confirmation.

## Generated content rules

- The title uses Conventional Commits style when appropriate and is limited to
  72 characters.
- The description preserves the repository Pull Request template.
- Checklist items remain unchecked for the author or reviewer to verify.
- The AI receives Git content as reference data and is instructed not to invent
  behavior, test results, or implementation details.
- Large diffs are truncated after 100,000 characters before being sent to the
  AI provider.

## Important side effects

The current branch is pushed before the generated Pull Request preview and
confirmation are displayed. Canceling at the final prompt prevents PR creation,
but it does not undo that push.

No Pull Request is created when:

- `swift test` fails;
- the working tree contains uncommitted changes;
- the current branch is `master`;
- a branch targeting `develop` does not follow `type/issue-description` and
  `--no-issue` was not used;
- the issue extracted from the branch does not exist or is inaccessible;
- the branch contains no commits relative to its base;
- an open Pull Request already exists for the same source and base;
- the AI command fails or returns invalid output;
- the user declines the final confirmation.

Temporary prompt, response, error, and body files are removed when the script
exits.

## Troubleshooting

### GitHub CLI is not authenticated

Run:

```sh
gh auth login
```

### The working tree is not clean

Commit or stash all local changes before creating the Pull Request:

```sh
git status
```

### Package tests fail

Run `swift test` directly, correct the build or test failure, and retry the
script.

### A Pull Request already exists

Open the URL printed by the script and continue working with the existing Pull
Request instead of creating a duplicate.

### The branch name is rejected

Rename the branch so the related issue number appears immediately after its
first slash:

```sh
git branch -m feat/7-media-type
```
