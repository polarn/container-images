# apt-repo-update

Tooling image for the `apt-repo-update` CronJob in
[polarn/flux](https://github.com/polarn/flux)
(`apps/microk8s/apt/apt-repo-update.yaml`), which reindexes the in-cluster
`env-exec` apt repository every 5 minutes.

- **Image:** `ghcr.io/polarn/apt-repo-update`, pinned by digest in flux
- **Base:** `debian:trixie-slim` — the estate is Debian 13; ~150 MB built
- **Update script:** stays in the CronJob's ConfigMap, *not* baked in, so it can
  be changed without rebuilding this image

## Why

The job used to run `apt-get install dpkg-dev gzip coreutils` on every tick:
125 packages and 103 MB of archives per run, ~32 GB/day from `deb.debian.org`,
to execute one Perl script.

Efficiency was the lesser reason. That download-and-unpack was also the blast
radius — on 2026-08-18 a replayed CronJob backlog ran ~30 of these at once and
drove a 2-core node into swap thrash until kubelet stopped posting node status.
Baked in, the same herd is nearly harmless. Runs went 56s to 7s.

## Possible slimming

69 MB of the image is perl (`dpkg-scanpackages` is a Perl script) plus binutils,
which `dpkg-dev` depends on and the job never calls. `apt-ftparchive`
(`apt-utils`, no perl) generates `Packages`, `Packages.gz` and a `Release` with
all three checksum sets natively, replacing both `dpkg-scanpackages` and the
hand-rolled checksum loops in the ConfigMap script.

Left as a separate change: it alters index generation, not packaging.
