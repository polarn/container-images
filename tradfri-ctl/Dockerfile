# tradfri-ctl — DIRIGERA hub control CLI from polarn/waybar-modules,
# packaged for the daily Sonos-rotation CronJob in the flux repo.
#
# Static stdlib-only binary, so the runtime stage is `scratch`. No CA
# bundle needed: the client deliberately skips TLS verification (the hub
# ships a self-signed cert), and no tzdata: rotation math uses UTC.

# ---- build stage ----
FROM docker.io/library/golang:1.25-bookworm@sha256:ea341baa9bd5ba6784f6d7161ace70544349a6242d54d34a0fbfd2c4d51c9d58 AS build

ARG SRC_REPO=https://github.com/polarn/waybar-modules
ARG SRC_REF=a4f26c7a350cb87afc3e0940800f0e47df6561d1

WORKDIR /src
RUN git clone "${SRC_REPO}" . \
 && git checkout "${SRC_REF}"
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /tradfri-ctl ./cmd/tradfri-ctl

# ---- runtime stage ----
FROM scratch

COPY --from=build /tradfri-ctl /tradfri-ctl

USER 65534:65534
ENTRYPOINT ["/tradfri-ctl"]
