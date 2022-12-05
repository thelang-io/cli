#!/usr/bin/env bash

#
# Copyright (c) 2018 Aaron Delasy
# Licensed under the MIT License
#

set -e

panic () {
  echo "Error: $@" 1>&2
  exit 1
}

if [[ "$OSTYPE" == "darwin"* ]]; then
  cdn_url="https://cdn.thelang.io/cli-core-macos"
  install_path="/usr/local/bin/the"
elif
  [[ "$OSTYPE" == "cygwin" ]] ||
  [[ "$OSTYPE" == "msys" ]] ||
  [[ "$OSTYPE" == "win32" ]]
then
  cdn_url="https://cdn.thelang.io/cli-core-windows"
  install_path="C:\Program Files\The\the.exe"
elif
  [[ "$OSTYPE" == "linux"* ]]
then
  cdn_url="https://cdn.thelang.io/cli-core-linux"
  install_path="/usr/local/bin/the"
else
  panic "unknown platform"
fi

echo "Installing The CLI..."
curl -o "$install_path" -s "$cdn_url"
chmod +x "$install_path"
echo "Successfully installed The CLI!"
echo "  Type \`the -h\` to explore available options"
