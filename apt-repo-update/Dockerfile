# Tooling for the apt-repo-update CronJob in polarn/flux. See README.md for why
# this image exists instead of apt-installing on every tick.
FROM debian:trixie-slim

# apt-ftparchive is all the job needs beyond the base -- gzip and coreutils are
# already there. apt-utils adds ~1.3MB; dpkg-dev, which this replaced, added
# 68MB of perl and binutils.
RUN apt-get update \
 && apt-get install -y --no-install-recommends apt-utils \
 && rm -rf /var/lib/apt/lists/*
