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
  if [[ "$OSTYPE" == "darwin"* ]]; then
    cdn_url="https://cdn.thelang.io/cli-core-macos-$(uname -m)"
    mkdir -p "$HOME/.the/bin"
    install_path="$HOME/.the/bin/the"
  elif
    [[ "$OSTYPE" == "cygwin" ]] ||
    [[ "$OSTYPE" == "msys" ]] ||
    [[ "$OSTYPE" == "win32" ]]
  then
    cdn_url="https://cdn.thelang.io/cli-core-windows"
    install_path="C:/Program Files/The/the.exe"
  elif
    [[ "$OSTYPE" == "linux"* ]]
  then
    cdn_url="https://cdn.thelang.io/cli-core-linux"
    install_path="/usr/bin/the"
  else
    panic "unknown platform"
  fi

  echo "Installing The CLI..."
  curl -fsSL "$cdn_url" -o "$install_path" || panic "failed to download and install"
  chmod +x "$install_path" || panic "failed to set permissions"

  if [[ "$OSTYPE" == "darwin"* ]]; then
    profile_file="$HOME/.zprofile"
    profile_content="export PATH=\"\$PATH:$HOME/.the/bin\" # Added by the-install (https://docs.thelang.io/install)"

    if [ -s "$profile_file" ] && [ -n "$(tail -c 1 < "$profile_file")" ]; then
      profile_content="$(printf "\n%s" "$profile_content")"
    fi

    echo "$profile_content" >> "$profile_file" || panic "failed to add to PATH"
  fi

  echo "Successfully installed The CLI!"
  echo "  Type \`the -h\` to explore available options"
}

main $@
