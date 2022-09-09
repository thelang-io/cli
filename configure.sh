#!/usr/bin/env bash

#
# Copyright (c) 2018 Aaron Delasy
# Licensed under the MIT License
#

set -e

curl -o /usr/local/bin/the -s https://cdn.thelang.io/the
chmod +x /usr/local/bin/the
