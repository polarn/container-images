# Tooling for the apt-repo-update CronJob in polarn/flux. See README.md for why
# this image exists instead of apt-installing on every tick.
FROM debian:trixie-slim

# dpkg-scanpackages is all the job needs beyond the base -- gzip, coreutils and
# findutils are already there. --no-install-recommends because dpkg-dev
# otherwise pulls a full C/C++ toolchain, fonts and image codecs.
RUN apt-get update \
 && apt-get install -y --no-install-recommends dpkg-dev \
 && rm -rf /var/lib/apt/lists/*
