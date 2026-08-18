# apt-repo-update

Tooling image for the `apt-repo-update` CronJob in
[polarn/flux](https://github.com/polarn/flux)
(`apps/microk8s/apt/apt-repo-update.yaml`), which regenerates the index of the
in-cluster `env-exec` apt repository every 5 minutes.

- **Image:** `ghcr.io/polarn/apt-repo-update`
- **Base:** `debian:trixie-slim`
- **Contents:** `dpkg-dev` (for `dpkg-scanpackages`), installed with
  `--no-install-recommends`
- **Size:** ~150 MB, of which 81 MB is the base

The update script itself is **not** in this image — it stays in the CronJob's
ConfigMap so it can be changed without a rebuild. This image only supplies the
tooling.

## Why it exists

The job previously ran `apt-get update && apt-get install -y dpkg-dev gzip
coreutils` against `debian:bookworm-slim` on *every* 5-minute tick. Measured
from a real run: **125 packages, 103 MB of archives** plus 9.4 MB of package
indices — roughly **32 GB/day** from `deb.debian.org`, to execute one Perl
script.

Two things were wrong with that line:

- `gzip` and `coreutils` are already in the base image (`apt-get` reported
  `already the newest version` for both), so two of the three packages were
  no-ops.
- `apt-get install` takes Recommends by default, and `dpkg-dev`'s pull in a
  whole C/C++ toolchain: `build-essential`, `gcc-12`, `g++-12`, `binutils`,
  `libasan8`, `fakeroot`, `gnupg`, plus fonts (`fonts-dejavu-core`) and image
  codecs (`libaom3`, `libavif15`, `libdav1d6`, `libde265-0`). None of it is
  used.

**It also set the blast radius, which is the real reason this image exists.** On
2026-08-18 a wedged apiserver watch froze the CronJob controller for 9.5h; when
it recovered it replayed the backlog as ~30 concurrent jobs, each doing that
download-and-unpack. They landed on one 2-core, 4 GB node and drove it to load
70 and swap thrash until kubelet stopped posting node status — which wedged
*that* node's watch layer in turn and took Grafana down for 17 minutes. With the
tooling baked in, the same herd is close to harmless: no network, no dpkg
unpack, just a script per pod.

## Why trixie

Both Proxmox hypervisors and the qnetd Pi run Debian 13; bookworm is being
retired in this estate. Nothing in a generated `Packages` index depends on the
builder's distro, so there was no reason to start a new image on oldstable.

## Known fat, and how to remove it

69 MB of the image is `dpkg-scanpackages` being a Perl script:
`libperl5.40` (29 MB), `perl-modules-5.40` (20 MB) and `perl-base` (8 MB),
plus `binutils` (~22 MB) which `dpkg-dev` depends on but the job never calls.

`apt-ftparchive` (from `apt-utils`, a few MB, no Perl) generates `Packages`,
`Packages.gz` **and** a `Release` file with all three checksum sets natively —
replacing both `dpkg-scanpackages` and the three hand-rolled checksum loops in
the ConfigMap script. That would cut the image to roughly the base size and
delete ~20 lines of shell. Deliberately left as a separate change, so a
behaviour change to index generation is not mixed into a packaging change.

## Verifying a build

The script runs unchanged in this image; it needs `dpkg-scanpackages`, `gzip`,
`md5sum`, `sha1sum`, `sha256sum`, `stat`, `find`, `date`, `sed`, `sort`, `cut`,
`cat` and `mkdir`, all present. To check end to end, build a throwaway `.deb`
into a `pool/main` and run the script against it — it should emit
`dists/stable/{Release,main/binary-amd64/Packages,main/binary-amd64/Packages.gz}`
and the `Release` should carry `MD5Sum:`, `SHA1:` and `SHA256:` sections.
