#!/usr/bin/env bash

#
# Copyright (c) Aaron Delasy
# Licensed under the MIT License
#

panic () {
  echo "Error: $@" 1>&2
  exit 1
}

main () {
  install_dir="$HOME/.the/bin"
  install_path="$install_dir/the"
  [[ ! -d "$install_dir" ]] && mkdir -p "$install_dir"

  if [[ "$OSTYPE" == "darwin"* ]]; then
    cdn_url="https://cdn.thelang.io/cli-core-macos-$(uname -m)"
  elif [[ "$OSTYPE" == "linux"* ]]; then
    cdn_url="https://cdn.thelang.io/cli-core-linux"
  else
    panic "unknown platform"
  fi

  echo "Installing The CLI..."
  curl -fsSL "$cdn_url" -o "$install_path" || panic "failed to download and install"
  chmod +x "$install_path" || panic "failed to set permissions"

  profile_file="$HOME/.zprofile"
  [[ ! -e "$profile_file" ]] && profile_file="$HOME/.bash_profile"
  [[ ! -e "$profile_file" ]] && profile_file="$HOME/.profile"

  profile_content="export PATH=\"\$PATH:$HOME/.the/bin\" # Added by the-install (https://docs.thelang.io/install)"

  if [ -s "$profile_file" ] && [ -n "$(tail -c 1 < "$profile_file")" ]; then
    profile_content="$(printf "\n%s" "$profile_content")"
  fi

  echo "$profile_content" >> "$profile_file" || panic "failed to add to PATH"
  echo "Successfully installed The CLI!"
  echo "  Type \`the -h\` to explore available options"
}

main $@
