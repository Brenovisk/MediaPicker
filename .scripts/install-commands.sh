#!/bin/sh

set -eu

repository_root=$(git rev-parse --show-toplevel)
install_directory="${XDG_BIN_HOME:-$HOME/.local/bin}"

mkdir -p "$install_directory"

install_command() {
  command_name="$1"
  source_path="$2"
  destination_path="$install_directory/$command_name"

  if [ -e "$destination_path" ] || [ -L "$destination_path" ]; then
    if [ -L "$destination_path" ] &&
      [ "$(readlink "$destination_path")" = "$source_path" ]; then
      echo "Command already installed: $command_name"
      return
    fi

    echo "error: $destination_path already exists and was not changed." >&2
    exit 1
  fi

  ln -s "$source_path" "$destination_path"
  echo "Installed command: $command_name"
}

install_command \
  "create-commit" \
  "$repository_root/.scripts/create-commit/create-commit.sh"

install_command \
  "create-pr" \
  "$repository_root/.scripts/create-pr/create-pr.sh"

install_command \
  "clean-gone-branches" \
  "$repository_root/.scripts/clean-gone-branches.sh"

case ":$PATH:" in
  *":$install_directory:"*)
    ;;
  *)
    echo "warning: Add $install_directory to PATH before using the commands." >&2
    ;;
esac
