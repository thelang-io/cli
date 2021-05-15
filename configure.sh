#!/usr/bin/env bash

#
# Copyright (c) 2021-present Aaron Delasy
# Licensed under the MIT License
#

set -e

sudo curl -o /usr/local/bin/the -s https://cdn.thelang.io/the@latest
sudo chmod +x /usr/local/bin/the
