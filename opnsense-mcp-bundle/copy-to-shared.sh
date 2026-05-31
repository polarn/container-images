#!/bin/sh
# Populate a shared volume with everything Bifrost needs to run the OPNsense MCP
# server in-process: the node runtime, the two shared libs the stock (minimal)
# Bifrost Alpine image lacks, and the installed npm package with its deps.
set -eu

DEST="${SHARED_DIR:-/shared}"
mkdir -p "$DEST/lib"

cp /usr/local/bin/node "$DEST/node"
cp /usr/lib/libstdc++.so.6 "$DEST/lib/"
cp /usr/lib/libgcc_s.so.1 "$DEST/lib/"

# Whole global node_modules tree (named node_modules so dep resolution works:
# node walks up from opnsense-mcp-server/dist and finds sibling deps here).
rm -rf "$DEST/node_modules"
cp -a /usr/local/lib/node_modules "$DEST/node_modules"

echo "opnsense-mcp-bundle: populated $DEST"
ls -la "$DEST"
