#!/usr/bin/env bash

set -euo pipefail

repository_root=$(git rev-parse --show-toplevel)
version_file="$repository_root/.openspec-version"

if [[ ! -f "$version_file" ]]; then
  echo "error: $version_file was not found." >&2
  exit 1
fi

if ! command -v openspec >/dev/null 2>&1; then
  echo "error: OpenSpec is required for repository validation." >&2
  echo "Install it with: npm install --global @fission-ai/openspec@$(tr -d '[:space:]' < "$version_file")" >&2
  exit 1
fi

expected_version=$(tr -d '[:space:]' < "$version_file")
installed_version=$(openspec --version | tr -d '[:space:]' | sed 's/^v//')

if [[ "$installed_version" != "$expected_version" ]]; then
  echo "error: OpenSpec $expected_version is required; found $installed_version." >&2
  echo "Install it with: npm install --global @fission-ai/openspec@$expected_version" >&2
  exit 1
fi

cd "$repository_root"

echo "Checking OpenSpec project health..."
openspec doctor

echo "Validating OpenSpec artifacts..."
openspec validate --all --strict --no-interactive

echo "Checking archived OpenSpec tasks..."
openspec validate --archived --strict --no-interactive
