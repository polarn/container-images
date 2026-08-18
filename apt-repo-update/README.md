# apt-repo-update

Tooling image for the `apt-repo-update` CronJob in
[polarn/flux](https://github.com/polarn/flux)
(`apps/microk8s/apt/apt-repo-update.yaml`), which reindexes the in-cluster
`env-exec` apt repository every 5 minutes.

- **Image:** `ghcr.io/polarn/apt-repo-update`, pinned by digest in flux
- **Base:** `debian:trixie-slim` — the estate is Debian 13; ~82 MB built
- **Contents:** `apt-utils`, for `apt-ftparchive`
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

## apt-ftparchive, not dpkg-scanpackages

`apt-ftparchive` emits `Packages`, `Packages.gz` and a `Release` carrying every
checksum set natively, so it replaced both `dpkg-scanpackages` and ~20 lines of
hand-rolled md5/sha1/sha256 loops in the ConfigMap script. It also needs neither
perl nor binutils, which is the difference between 82 MB and 149 MB.

Two deliberate changes to the published index, both verified against a real apt
client:

- **Every version is listed, not just the newest.** `dpkg-scanpackages` without
  `--multiversion` wrote one entry per package and warned about the rest, so
  older `env-exec` releases could not be installed. The install candidate is
  unchanged; the older versions are simply reachable now.
- **A SHA512 section is added.** apt uses the strongest digest on offer.
