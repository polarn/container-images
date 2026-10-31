# Plan

Work queued for this repo. Each item says what done looks like. Remove an item once it lands; its commit body keeps the reasoning.

## 1. Rework how images of our own code are built

Decided 2026-10-31: an image of our own code is built in the repo that holds the code, by a workflow on push to `main` with `paths:` filters (GitHub evaluates those over the whole push, so the `HEAD^..HEAD` problem below does not apply there), tagged by commit SHA under the old `ghcr.io/polarn/<name>` so flux can roll back to a digest built here. Flux still gets the digest by a manual pin, read from the run summary. `bambu-exporter` is done: `polarn/bambu` holds its Dockerfile and `build.yml`, flux runs that image, and the folder here is gone. The ghcr package needed a one-off *Manage Actions access* grant for the new repo.

Left:

- `volvo-exporter`: the same Dockerfile and workflow in `polarn/volvo`, a flux repin, then delete the folder here. The package already grants `polarn/volvo` write access.
- `tradfri-ctl` stays here for now: it is a CLI in polarn/waybar-modules, which has no image workflow, and it changes about once a year, so a `SRC_REF` bump is cheaper than a workflow there. Say so in the README when the volvo item lands.
- `build.yml`'s `detect` still diffs `HEAD^..HEAD`, so a push of two commits builds only the images the last one touched. Diff from `github.event.before` instead.

Done: this repo holds only third-party-source images plus `tradfri-ctl` with the README saying why, and the READMEs here and in the flux apps describe the new release path.
