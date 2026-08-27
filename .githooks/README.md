# Git hooks

Install the repository hooks once after cloning:

```sh
./.githooks/install-git-hooks.sh
```

The `pre-push` hook finds the `MediaPicker` package, runs the pinned SwiftLint
configuration, and then runs `swift test`. Git cancels the push when linting,
the build, or any test fails. A push can still be explicitly bypassed with
`git push --no-verify` when necessary.

On macOS, the hook resolves `SDKROOT` through `xcrun` so the Swift compiler and
SDK both come from the Xcode selected by `xcode-select`.
