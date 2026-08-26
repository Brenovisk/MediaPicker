# Create Pull Request

Validates the package, synchronizes the current branch, generates a Pull Request
title and description with an AI provider, and creates the Pull Request through
the GitHub CLI.

The generated description follows `.github/pull-request-template.md` and is
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

## Setup

Make the script executable once:

```sh
chmod +x .scripts/create-pr/create-pr.sh
```

Run it from the repository root with a clean working tree. All intended changes
must already be committed.

## Usage

Choose the AI provider interactively:

```sh
.scripts/create-pr/create-pr.sh
```

Or provide it as the first argument:

```sh
.scripts/create-pr/create-pr.sh codex
.scripts/create-pr/create-pr.sh claude
.scripts/create-pr/create-pr.sh gemini
```

## Branch targeting

The base branch is selected automatically:

| Current branch | Pull Request base |
| --- | --- |
| `develop` | `master` |
| Any other non-`master` branch | `develop` |
| `master` | Not allowed |

This supports feature branches merging into `develop`, followed by release Pull
Requests from `develop` into `master`.

## What the script does

1. Runs `swift test` before any Pull Request preparation.
2. Stops if the package does not compile or any test fails.
3. Validates Git, GitHub CLI authentication, and the selected AI CLI.
4. Resolves the current and base branches.
5. Requires a clean working tree and an `origin` remote.
6. Fetches the base branch and verifies that the current branch has commits to
   propose.
7. Pushes the current branch, configuring its upstream when necessary.
8. Stops if an open Pull Request already exists for the same branch pair.
9. Collects commits, changed files, statistics, the Git diff, and the repository
   Pull Request template.
10. Generates and validates a title and description with the selected AI.
11. Shows the complete proposal and asks for confirmation.
12. Creates the Pull Request with `gh pr create` after confirmation.

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
