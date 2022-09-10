#!/usr/bin/env bash

#
# Copyright (c) 2018 Aaron Delasy
# Licensed under the MIT License
#

set -e

cat << 'EOF' > /usr/local/bin/the
{{ CLI_CONTENT }}
EOF

chmod +x /usr/local/bin/the
