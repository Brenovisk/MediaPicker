#!/bin/sh

set -eu

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
    echo "error: This command must be executed inside a Git repository." >&2
    exit 1
}

echo "Pruning remote-tracking branches..."
git fetch --prune

current_branch=$(git branch --show-current)
gone_branches=$(
    git for-each-ref \
        --format='%(refname:short) %(upstream:track)' \
        refs/heads \
        | awk '$NF == "[gone]" { print $1 }'
)

if [ -z "$gone_branches" ]; then
    echo "No gone local branches found."
    exit 0
fi

echo "$gone_branches" | while IFS= read -r branch_name; do
    if [ "$branch_name" = "$current_branch" ]; then
        echo "Skipping current branch: $branch_name"
        continue
    fi

    echo "Deleting merged branch: $branch_name"
    git branch -d -- "$branch_name"
done
