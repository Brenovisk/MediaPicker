# Create Commit

Runs SwiftLint, then creates one or more focused Git commits from the changes
currently staged in the repository. An AI provider analyzes the staged diff,
proposes a commit plan, and generates messages that follow the project's
issue-based convention.

The script always shows the complete plan and asks for confirmation before it
creates any commit.

## Requirements

- Bash
- Git
- `jq`
- One installed and authenticated AI CLI:
  - Claude Code (`claude`)
  - Codex (`codex`)
  - Gemini (`gemini`)

The command must be run from inside the MediaPicker Git repository.

## Install commands

Install the repository command launchers once after cloning:

```sh
./.scripts/install-commands.sh
```

This creates `create-commit` and `create-pr` links in
`${XDG_BIN_HOME:-$HOME/.local/bin}`. The installer does not replace an existing
file or a command installed from another location.

## Setup

Stage only the changes that should be considered for the commits:

```sh
git add <files>
```

## Usage

Choose the AI provider interactively:

```sh
create-commit
```

Or provide it as the first argument:

```sh
create-commit codex
create-commit claude
create-commit gemini
```

On feature branches, the script extracts the issue number automatically from
the branch name:

```text
feat/7-media-type
fix/14-camera-permission
chore/5-contribution-conventions
```

These branches produce commit scopes `(7)`, `(14)`, and `(5)`, respectively.
Branches other than `develop` and `master` must follow this convention.

On `develop` or `master`, the script asks for the issue number because those
branch names do not identify one. Both `4` and `#4` are accepted when prompted.

## Commit format

Every generated message follows this format:

```text
type(issue): emoji description
```

Example:

```text
ci(4): 👷 add package validation workflow
```

Supported types are `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `ci`,
`build`, `perf`, and `style`.

## What the script does

1. Validates Git, `jq`, and the repository, then runs the pinned SwiftLint
   configuration and stops if linting fails.
2. Validates the selected AI CLI and extracts the issue number from the branch,
   or requests it on `develop` and
   `master`.
3. Reads only the staged files and staged diff.
4. Rejects files that contain both staged and unstaged changes.
5. Asks the AI provider to produce one logical commit or a small set of
   independent commits.
6. Validates the returned JSON, commit types, fields, and file assignments.
7. Ensures every staged file appears exactly once in the plan.
8. Displays the proposed messages and the files assigned to each commit.
9. Creates the commits only after explicit confirmation.

When multiple commits are approved, the script temporarily unstages the
original set, stages each planned file group, and commits the groups in order.
It does not split individual hunks from the same file.

## Safety rules

- Unstaged-only files are ignored.
- A staged file cannot appear in more than one generated commit.
- The AI cannot add a file that was not originally staged.
- Every originally staged file must be included in the plan.
- Files with both staged and unstaged edits cause the script to stop, preventing
  accidental inclusion of work that was not selected.
- Temporary prompt and response files are removed when the script exits.
- Answering anything other than `y` at confirmation cancels without creating
  commits.

## Troubleshooting

### There are no staged changes

Stage the intended files and run the command again:

```sh
git add <files>
```

### A file has staged and unstaged changes

Finish staging the intended state or stash the unstaged portion. The script
does not perform hunk-level commit splitting.

### The AI output is rejected

Run the command again or select another provider. The script rejects malformed
JSON, unsupported commit types, missing files, duplicate file assignments, and
files that were not staged.

### The branch name is rejected

Rename the branch so the issue number appears immediately after its first
slash:

```sh
git branch -m feat/7-media-type
```
