# Create Commit

Creates one or more focused Git commits from the changes currently staged in
the repository. An AI provider analyzes the staged diff, proposes a commit plan,
and generates messages that follow the project's issue-based convention.

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

## Setup

Make the script executable once:

```sh
chmod +x .scripts/create-commit/create-commit.sh
```

Stage only the changes that should be considered for the commits:

```sh
git add <files>
```

## Usage

Choose the AI provider interactively:

```sh
.scripts/create-commit/create-commit.sh
```

Or provide it as the first argument:

```sh
.scripts/create-commit/create-commit.sh codex
.scripts/create-commit/create-commit.sh claude
.scripts/create-commit/create-commit.sh gemini
```

The script then asks for the related GitHub issue number. Both `4` and `#4`
are accepted.

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

1. Validates Git, `jq`, the repository, and the selected AI CLI.
2. Requests and validates the issue number.
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
