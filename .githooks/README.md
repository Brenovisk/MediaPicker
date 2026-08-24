# Git hooks

Install the repository hooks once after cloning:

```sh
./Scripts/install-git-hooks.sh
```

The `pre-push` hook finds the `MediaPicker` package and runs `swift test`. Git
cancels the push when the build or any test fails. A push can still be
explicitly bypassed with `git push --no-verify` when necessary.
