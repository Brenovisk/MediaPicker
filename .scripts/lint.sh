#!/bin/sh

set -eu

repository_root=$(git rev-parse --show-toplevel)
version_file="$repository_root/.swiftlint-version"

if ! command -v swiftlint >/dev/null 2>&1; then
    echo "error: SwiftLint is required. Install it with: brew install swiftlint" >&2
    exit 1
fi

if [ ! -f "$version_file" ]; then
    echo "error: .swiftlint-version was not found." >&2
    exit 1
fi

required_version=$(tr -d '[:space:]' < "$version_file")
installed_version=$(swiftlint version)

if [ "$installed_version" != "$required_version" ]; then
    echo "error: SwiftLint $required_version is required; found $installed_version." >&2
    exit 1
fi

cd "$repository_root"
swiftlint lint --no-cache --config .swiftlint.yml
