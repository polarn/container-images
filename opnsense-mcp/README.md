# opnsense-mcp

OPNsense MCP server image, built from [coreyhines/opnsense-mcp](https://github.com/coreyhines/opnsense-mcp).

- **Image:** `ghcr.io/polarn/opnsense-mcp`
- **Upstream commit (pinned):** [`c292119`](https://github.com/coreyhines/opnsense-mcp/commit/c29211910cb430bbe8a6d0ebebadae12c57f499a) — set via the `SRC_REF` build-arg
- **Transport:** streamable HTTP on `:8765/mcp` (FastMCP native)

## Why this upstream

Replaces the vespo92/OPNSenseMCP build (and the in-process
`opnsense-mcp-bundle` stdio delivery of the same package): vespo92's `ssh_*`
tools crash the whole server on any SSH failure (unhandled `'error'` emit,
unfixed at HEAD) and its DHCP tools only query the legacy ISC backend, which
returns nothing on a dnsmasq-based OPNsense 25.x. coreyhines is dnsmasq-aware
— DHCP host reservations (`mk_dhcp_host`, `move_dhcp_host`,
`dhcp_lease_delete`) with dry-run-by-default mutations — plus ARP/LLDP
discovery, firewall rules, logs, and packet capture. FastMCP's native
streamable-http is a reference implementation, not a stdio→HTTP bridge, so the
bridge fragility that motivated the bundle pattern doesn't apply.

Deps install with `uv sync --frozen` from upstream's committed `uv.lock`;
base + source both pinned; runtime is non-root (`nobody`), API-only (no
openssh-client — the optional SSH toolset is unused).

## Runtime env (supplied by the deployment)

| Var | Purpose |
|-----|---------|
| `OPNSENSE_FIREWALL_HOST` | bare host, e.g. `192.168.1.1` (scheme is added internally) |
| `OPNSENSE_API_KEY` / `OPNSENSE_API_SECRET` | OPNsense API credentials |
| `OPNSENSE_SSL_VERIFY` | `true` / `false` (default `false`) |

Without credentials the server boots with a mock client — useful as a smoke
test, useless in production; check the logs for "Using real OPNsense client".

## Bumping upstream

Edit `SRC_REF` in the `Dockerfile` to a newer reviewed commit, commit, push — CI rebuilds
and pushes a new digest. Then pin that digest in the [polarn/flux](https://github.com/polarn/flux)
manifest.
