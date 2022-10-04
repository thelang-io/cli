#!/usr/bin/env bash

#
# Copyright (c) 2018 Aaron Delasy
# Licensed under the MIT License
#

set -e
echo "Installing The CLI..."

if [[ "$OSTYPE" == "darwin"* ]]; then
  curl -o /usr/local/bin/the -s https://cdn.thelang.io/cli-core-macos
elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
  curl -o /usr/local/bin/the -s https://cdn.thelang.io/cli-core-windows
else
  curl -o /usr/local/bin/the -s https://cdn.thelang.io/cli-core-linux
fi

chmod +x /usr/local/bin/the

echo "Successfully installed The CLI!"
echo "  Type \`the -h\` to explore available options"
