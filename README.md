# container-images

Custom container images for homelab services, built by GitHub Actions and pushed to
`ghcr.io/polarn/<image>`.

One folder per image, each with its own `Dockerfile` and `README`. A push to `main` that
touches an image folder rebuilds just that image; `workflow_dispatch` can rebuild a chosen
image (or all) on demand. Images are referenced from the
[polarn/flux](https://github.com/polarn/flux) GitOps repo by SHA digest.

| Image | Source | Notes |
|-------|--------|-------|
| [`opnsense-mcp`](./opnsense-mcp) | [vespo92/OPNSenseMCP](https://github.com/vespo92/OPNSenseMCP) | OPNsense MCP, streamable-HTTP |

## Conventions

- Base images pinned by SHA digest; third-party source pinned by commit (`SRC_REF` build-arg).
- GitHub Actions pinned by commit SHA.
- Single-arch **amd64** — the cluster is amd64-only.
- New digests are pinned manually in flux (no automated image updates).
