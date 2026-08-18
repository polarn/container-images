# Tooling for the apt-repo-update CronJob in polarn/flux
# (apps/microk8s/apt/apt-repo-update.yaml).
#
# That job used to run `apt-get update && apt-get install -y dpkg-dev gzip
# coreutils` on debian:bookworm-slim on every 5-minute tick: 125 packages and
# 103MB of archives plus 9.4MB of indices, roughly 32GB/day from
# deb.debian.org, to run one Perl script. gzip and coreutils were already in
# the base image, and dpkg-dev's Recommends dragged in gcc, g++, binutils,
# fakeroot, gnupg, fonts and image codecs -- none of which the job uses.
#
# It also set the blast radius. On 2026-08-18 a replayed backlog of ~30
# concurrent jobs, each doing that download-and-unpack, drove a 2-core node to
# load 70 and swap thrash until kubelet stopped posting node status. With the
# tooling baked in, the same herd is close to harmless.
#
# trixie, not bookworm: both hypervisors and the qnetd Pi are Debian 13, and
# bookworm is being retired here. Nothing in a generated Packages index depends
# on the builder's distro.
#
# The update script itself stays in the ConfigMap so it can change without a
# rebuild; only the tooling lives here.
FROM debian:trixie-slim

# dpkg-dev supplies dpkg-scanpackages, the only thing the script needs beyond
# the base image -- gzip, coreutils and findutils are already present, all
# being essential or required packages.
RUN apt-get update \
 && apt-get install -y --no-install-recommends dpkg-dev \
 && rm -rf /var/lib/apt/lists/*
