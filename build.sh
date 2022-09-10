#!/usr/bin/env bash

#
# Copyright (c) 2018 Aaron Delasy
# Licensed under the MIT License
#

set -e

source version.sh

rm -rf dist
mkdir -p dist

cli_content=$(<cli.sh)
install_content=$(<install.sh)

cli_content="${cli_content/\{\{ VERSION_NAME \}\}/$VERSION_NAME}"
cli_content="${cli_content/\{\{ VERSION_NUM \}\}/$VERSION_NUM}"
install_content="${install_content/\{\{ CLI_CONTENT \}\}/$cli_content}"

echo "$install_content" > dist/cli.sh
chmod +x dist/cli.sh
