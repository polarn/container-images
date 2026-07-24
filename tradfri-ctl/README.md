# tradfri-ctl

IKEA DIRIGERA hub control CLI, built from [polarn/waybar-modules](https://github.com/polarn/waybar-modules) (`cmd/tradfri-ctl`).

- **Image:** `ghcr.io/polarn/tradfri-ctl`
- **Source commit (pinned):** set via the `SRC_REF` build-arg in the `Dockerfile`
- **Runtime:** `scratch` + one static binary, runs as `nobody`

## What it's for

The `tradfri` CronJob in [polarn/flux](https://github.com/polarn/flux) runs
`tradfri-ctl rotate-music` daily: it rewrites a DIRIGERA scene (bound to a
SOMRIG shortcut button) to play a different Sonos favorite each day. The
rotation pool is defined by favorite-title prefix (e.g. `Isak: `) — add a
matching favorite in the Sonos app and it joins the rotation, no redeploy.

Other subcommands (`list`, `toggle`, `set`, `music`, `scenes`, `set-music`)
work too; see the source repo for docs.

## Runtime requirements

- Network reach to the hub (`--host <ip>`, HTTPS :8443, self-signed).
- A pairing token file mounted somewhere, passed via `--token <path>`
  (produced once by `waybar-tradfri-auth`; in flux it comes from a
  SOPS-encrypted Secret).

## Bumping the source

Edit `SRC_REF` in the `Dockerfile` to the new waybar-modules commit, push —
CI rebuilds and pushes a new digest. Then pin that digest in the flux
manifest.
