# Plan

Work queued for this repo. Each item says what done looks like. Remove an item once it lands; its commit body keeps the reasoning.

## 1. Rework how images of our own code are built

`bambu-exporter`, `volvo-exporter` and `tradfri-ctl` are built from polarn/waybar-modules, so every release takes three commits in three repos: the source change, a `SRC_REF` bump here, and a digest pin in polarn/flux. The pattern came from the third-party images, whose upstreams can't hold our Dockerfiles; nothing records a reason to keep our own code on it.

Decide, then do:

- **Where the build runs.** Either a workflow in waybar-modules that builds each image on a push to `main` touching its `cmd/<name>/`, `pkg/` or `go.mod`, tagged by commit SHA, or keep this repo but trigger it from waybar-modules instead of hand-bumping `SRC_REF`.
- **How the image is made.** The three Dockerfiles are the same static Go build on `scratch` with a CA bundle; `ko`, or one parameterised Dockerfile, would replace them.
- **How flux gets the digest.** The convention is a manual pin. Flux image automation (`ImageRepository`, `ImagePolicy`, `ImageUpdateAutomation`) or Renovate could open or push the bump instead; decide whether a reviewed pin still matters for these three.
- Whatever builds them must diff the whole push (`github.event.before`), not `HEAD^..HEAD` as `build.yml`'s `detect` does now: a push of two commits builds only the images the last one touched.
- Keep the old `ghcr.io/polarn/<name>` image names and their existing tags, so flux can roll back to a digest built here.

Done: a waybar-modules change to one of the three reaches the cluster with at most one manual step, this repo holds only third-party-source images (or the README says why it still holds ours), and the READMEs here, in waybar-modules and in the flux apps describe the new release path.
