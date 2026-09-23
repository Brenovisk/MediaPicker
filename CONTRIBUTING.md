# Contributing to MediaPicker

Thank you for helping improve MediaPicker. The project targets iOS 17 or later,
uses Swift 6, and intentionally has no third-party runtime dependencies.

## Before starting

- Search existing issues before opening a new one.
- Use the bug or feature issue template and keep each issue focused on one
  independently reviewable change.
- For significant public-API or architecture changes, discuss the approach in
  an issue before implementation.
- Base work on `develop`. Reserve `master` for release-ready changes.

## Branches

Create a short-lived branch from an up-to-date `develop` branch. Use the issue
number and a concise kebab-case description:

```text
feature/42-add-photo-filter
fix/42-handle-denied-permission
docs/42-explain-camera-privacy
chore/42-update-ci
```

Open pull requests into `develop`. Keep branches limited to one issue and avoid
mixing unrelated refactors with a functional change.

## Spec-driven development with OpenSpec

OpenSpec is the planning framework for new features and significant behavior
changes. Its CLI is a development-only tool and must not be added to
`Package.swift`. The required version is stored in `.openspec-version`. Install
Node.js 20.19 or newer, install that exact version, and verify the repository
setup with:

```sh
npm install --global @fission-ai/openspec@1.13.1
openspec --version
./.scripts/validate-openspec.sh
```

Create an OpenSpec proposal before production code changes when work introduces
a feature, changes public API or observable behavior, alters architecture or
concurrency, or significantly changes permissions, media processing, storage,
or lifecycle behavior. A proposal is not required for typos, formatting,
dependency-free documentation, test-only maintenance, or a small localized fix
whose expected behavior and implementation are already unambiguous. If such a
fix expands into a significant behavior or design change, stop and create a
proposal.

Use this workflow:

1. Create the change and its proposal, requirements, design decisions,
   acceptance scenarios, and implementation tasks with
   `$openspec-propose <description>`.
2. Review the generated artifacts under `openspec/changes/<change-name>/` and
   run `./.scripts/validate-openspec.sh` before changing production code.
3. Implement the approved tasks with `$openspec-apply-change <change-name>`,
   keeping task checkboxes current as work is verified.
4. Run OpenSpec validation, lint, build, tests, and applicable manual checks.
5. After the implementation and acceptance criteria are complete, archive it
   with `$openspec-archive-change <change-name>` and validate again.

Commit `openspec/` and the generated tool workflows under `.agents/`; they are
shared project inputs. Personal OpenSpec configuration and worksets are stored
outside the repository and must not be committed. Pull requests must reference
the related `openspec/changes/<change-name>/` path when a proposal applies, or
state why OpenSpec is not applicable.

## Code style and naming

- Follow SOLID and Clean Code principles: keep types and functions focused on a
  single responsibility, depend on small abstractions at system boundaries,
  favor composition over inheritance, and make dependencies explicit.
- Prefer simple, readable designs over speculative abstractions. Remove
  duplication when it represents the same rule, keep functions small and at a
  consistent level of abstraction, use intention-revealing names, and avoid
  hidden side effects, boolean flag arguments, and premature generalization.
- Preserve testability when applying these principles. Isolate framework and
  hardware interactions behind focused boundaries, but do not introduce a
  protocol, layer, or dependency-injection mechanism unless it serves a current
  behavior or test.
- Follow the Swift API Design Guidelines and the naming used by Apple SDKs.
- Use four spaces for indentation, never tabs, and keep one declaration per
  source file when that improves discoverability.
- Name types and protocols with `UpperCamelCase`; name functions, properties,
  variables, and enum cases with `lowerCamelCase`.
- Prefer names that describe roles and intent. Avoid abbreviations unless they
  are established platform terms.
- Put the primary declaration first and focused private helpers afterward.
- Use explicit access control. Default to `internal`; expose only the API a
  package consumer needs.
- Add documentation comments to public APIs, including important error,
  cancellation, ownership, and lifetime behavior.
- Keep imports minimal and preserve the dependency direction described in
  [Docs/Architecture.md](Docs/Architecture.md).

### Formatting and warnings

Use Xcode's built-in Swift formatter (Editor > Structure > Re-Indent) for
touched code. A change should not reformat unrelated files. SwiftLint is the
mandatory linter for repository code and remains a development and CI tool; it
must never be added to `Package.swift` or become a consumer dependency. Its
version is fixed in `.swiftlint-version` and its rules in `.swiftlint.yml`.

Install the required version with Homebrew when it matches the pinned version,
then run the repository wrapper:

```sh
brew install swiftlint
./.scripts/lint.sh
```

The wrapper rejects a different SwiftLint version so local and CI results stay
consistent. New rules should be introduced deliberately, with existing
violations resolved in the same change and without reformatting unrelated code.

Treat new compiler warnings as defects. Pull requests must build without new
warnings under the Swift and Xcode versions used by CI. Do not silence warnings
with broad compiler flags or unchecked annotations. If a platform limitation
requires a narrow suppression, explain it in code and in the pull request.

## Swift 6 concurrency

- Enable and respect complete Swift 6 concurrency checking. Do not weaken the
  package's checking mode to make a diagnostic disappear.
- Keep UI-observed state and SwiftUI-facing operations on `@MainActor`.
- Serialize `AVCaptureSession` configuration and mutation away from the main
  actor so camera work cannot block UI updates.
- Prefer immutable `Sendable` values across isolation boundaries. Do not add
  `@unchecked Sendable` without documenting the invariant that makes it safe
  and covering that invariant with focused tests where possible.
- Use structured concurrency (`async`/`await`, task groups, and actors) in
  preference to detached tasks or unstructured callbacks.
- Check cancellation in long-running asynchronous work and release temporary
  resources when an operation is cancelled.
- Avoid `nonisolated(unsafe)`, global mutable state, blocking waits, and lock
  use unless the design is documented and reviewed.

## Testing

Tests use Swift Testing and mirror the source areas under
`Tests/MediaPickerTests`. Add or update focused tests for new isolated behavior,
regressions, error paths, and cancellation. Tests must be deterministic and
must not depend on camera hardware, the user's photo library, network access,
or execution order.

Before opening a pull request, run:

```sh
./.scripts/validate-openspec.sh
./.scripts/lint.sh
swift build
swift test
```

For presentation, camera, or recording changes, also build and exercise the
Example App on the relevant simulator or physical device. Record manual checks
in the pull request. Hardware-only behavior is manually verified; business
rules around it should still be isolated for automated testing.

### Pre-push Git hook

Install the repository's version-controlled Git hooks once after cloning:

```sh
./.githooks/install-git-hooks.sh
```

The `pre-push` hook runs OpenSpec validation, `./.scripts/lint.sh`, and
`swift test` before Git sends commits to the remote. A specification, lint,
build, or test failure cancels the push so problems are caught before CI. The
hook uses the same pinned OpenSpec and SwiftLint versions and configuration as
`create-commit`, `create-pr`, and GitHub Actions.

Keep the hooks installed and do not edit the installed copy directly; update
the version-controlled files under `.githooks` instead. `git push --no-verify`
may bypass the hook only for an exceptional, explicitly understood reason. It
does not bypass CI, and any skipped validation must be run before the pull
request is considered ready.

## Commits

Use the repository's `create-commit` command so commit messages and logical
file groupings remain consistent. Install the command launchers once after
cloning:

```sh
./.scripts/install-commands.sh
```

Stage only the intended changes, then run the command and select an AI provider:

```sh
git add <files>
create-commit
```

The provider can also be selected directly with `create-commit codex`,
`create-commit claude`, or `create-commit gemini`. The command reads only the
staged diff, but first validates OpenSpec and runs the pinned SwiftLint
configuration against the repository. It then proposes one or more focused
commits, validates every file assignment, generates the required
`type(issue): emoji description` messages, and asks for confirmation before
committing. Feature-branch names must include the issue number, such as
`fix/42-handle-denied-permission`, so the command can derive the commit scope.

For a change that intentionally has no corresponding issue, run
`create-commit --no-issue` (or, for example,
`create-commit codex --no-issue`). The command then omits the issue scope and
generates a message such as `fix: 🐛 correct camera orientation`.

Review the proposed plan before approving it. Do not stage generated files,
secrets, unrelated formatting, or changes belonging to another issue. See
[the create-commit guide](.scripts/create-commit/README.md) for supported types,
safety rules, and troubleshooting.

## Pull requests

Create pull requests with the repository's `create-pr` command:

```sh
create-pr
```

As with commits, a provider can be passed directly: `create-pr codex`,
`create-pr claude`, or `create-pr gemini`. Run it from a clean working tree
after all intended commits are ready. The command runs the package tests,
selects the correct base branch, validates the issue number from the branch,
pushes the branch, loads the repository pull-request template, generates a
consistent title and description, inserts the related issue, and shows the
complete proposal for confirmation before creating the pull request. OpenSpec
and SwiftLint run before the package tests, so any validation can stop the
operation.

When a pull request intentionally has no corresponding issue, use
`create-pr --no-issue` (or, for example, `create-pr codex --no-issue`). This
skips issue-number validation and leaves the Related Issues section empty.

Review the generated content carefully. It must accurately describe visible
behavior, technical decisions, validation, risks, and breaking changes. Leave
checklist items unchecked until they have actually been verified, and explain
any Definition of Done item that does not apply. Keep the pull request focused
on one issue and respond to review feedback with additional commits. See
[the create-pr guide](.scripts/create-pr/README.md) for branch targeting, side
effects, and troubleshooting.

## Definition of Done

A contribution is complete when the package builds without new warnings,
relevant automated tests and all existing tests pass, public APIs are coherent
and documented, errors and cancellation are handled, no required work is hidden
in `TODO` or `FIXME` comments, visible behavior is demonstrated in the Example
App, affected documentation is updated, and the pull request references its
issue and applicable OpenSpec proposal.
