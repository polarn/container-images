# opnsense-mcp

OPNsense MCP server image, built from [vespo92/OPNSenseMCP](https://github.com/vespo92/OPNSenseMCP).

- **Image:** `ghcr.io/polarn/opnsense-mcp`
- **Upstream commit (pinned):** [`fc93c9e`](https://github.com/vespo92/OPNSenseMCP/commit/fc93c9e883bbe19d9ae264a96c1dbe6668c6ea75) — set via the `SRC_REF` build-arg
- **Transport:** streamable HTTP on `:3000/mcp` (also exposes `/sse` and `/health`)

## Why a custom image

Upstream is published only as a stdio npm package with a Dockerfile that doesn't build
(`npm ci --only=production` runs before a `tsc` build that needs dev deps). This rebuilds
it multi-stage — slim runtime, non-root (`node` user), base + source both pinned. It runs
without postgres/redis (`ENABLE_CACHING=false`).

## Runtime env (supplied by the deployment)

| Var | Purpose |
|-----|---------|
| `OPNSENSE_HOST` | e.g. `https://192.168.1.1` |
| `OPNSENSE_API_KEY` / `OPNSENSE_API_SECRET` | OPNsense API credentials |
| `OPNSENSE_VERIFY_SSL` | `true` / `false` |
| `MCP_TRANSPORT` | defaults to `streamable-http` |
| `MCP_SSE_PORT` / `MCP_SSE_HOST` | defaults to `3000` / `0.0.0.0` |

## Bumping upstream

Edit `SRC_REF` in the `Dockerfile` to a newer reviewed commit, commit, push — CI rebuilds
and pushes a new digest. Then pin that digest in the [polarn/flux](https://github.com/polarn/flux)
manifest.
