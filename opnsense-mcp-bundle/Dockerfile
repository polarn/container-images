# opnsense-mcp-bundle — a "runtime delivery" image, NOT a long-running server.
#
# Used as an initContainer: it copies the node runtime, the two shared libs the
# minimal Bifrost Alpine image lacks (libstdc++, libgcc_s), and the installed
# opnsense-mcp-server package into a shared emptyDir. Bifrost then runs the MCP
# server in-process over stdio (command=/shared/node) — no HTTP bridge, which is
# the whole point: it sidesteps the stdio-over-HTTP session bugs that plague
# supergateway/mcp-proxy/etc.
#
# Pinned to opnsense-mcp-server (Pixelworlds) — the stdio server already validated
# at 144 tools.

FROM node:24-alpine@sha256:2bdb65ed1dab192432bc31c95f94155ca5ad7fc1392fb7eb7526ab682fa5bf14

ARG MCP_PKG_VERSION=0.11.0
RUN npm install -g "opnsense-mcp-server@${MCP_PKG_VERSION}"

COPY copy-to-shared.sh /usr/local/bin/copy-to-shared.sh
RUN chmod +x /usr/local/bin/copy-to-shared.sh

ENTRYPOINT ["/usr/local/bin/copy-to-shared.sh"]
