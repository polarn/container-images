# container-images

Custom container images for homelab services, built by GitHub Actions and pushed to
`ghcr.io/polarn/<image>`.

One folder per image, each with its own `Dockerfile` and `README`. A push to `main` that
touches an image folder rebuilds just that image; `workflow_dispatch` can rebuild a chosen
image (or all) on demand. Images are referenced from the
[polarn/flux](https://github.com/polarn/flux) GitOps repo by SHA digest.

| Image | Source | Notes |
|-------|--------|-------|
| [`bambu-exporter`](./bambu-exporter) | [polarn/waybar-modules](https://github.com/polarn/waybar-modules) | Bambu Lab printer telemetry on `scratch` (+CA bundle). Holds one cloud MQTT subscription open and serves Prometheus metrics plus a JSON state endpoint for the waybar pill. |
| [`tradfri-ctl`](./tradfri-ctl) | [polarn/waybar-modules](https://github.com/polarn/waybar-modules) | DIRIGERA hub CLI on `scratch`; used by the flux `tradfri` CronJob to rotate which Sonos favorite the SOMRIG button plays. |
| [`opnsense-mcp-bundle`](./opnsense-mcp-bundle) | [opnsense-mcp-server](https://www.npmjs.com/package/opnsense-mcp-server) (Pixelworlds) | initContainer that delivers node + the OPNsense MCP server into a shared volume, so Bifrost runs it **in-process over stdio** (no HTTP bridge). |
| [`opnsense-mcp`](./opnsense-mcp) | [vespo92/OPNSenseMCP](https://github.com/vespo92/OPNSenseMCP) | **Superseded** by `opnsense-mcp-bundle` — vespo92's streamable-HTTP + SSE are both broken against MCP SDK 1.24.x. Kept for reference; prune later. |

## Conventions

- Base images pinned by SHA digest; third-party source pinned by commit (`SRC_REF` build-arg).
- GitHub Actions pinned by commit SHA.
- Single-arch **amd64** — the cluster is amd64-only.
- New digests are pinned manually in flux (no automated image updates).
