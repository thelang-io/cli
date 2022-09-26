#!/usr/bin/env bash

#
# Copyright (c) 2018 Aaron Delasy
# Licensed under the MIT License
#

set -e
echo "Installing The CLI..."

cat << 'EOF' > /usr/local/bin/the
{{ CLI_CONTENT }}
EOF

chmod +x /usr/local/bin/the
echo "Successfully installed The CLI!"
echo "  Type \`the -h\` to explore available options"
