# bambu-exporter — Bambu Lab cloud telemetry from polarn/waybar-modules,
# packaged for the flux `bambu-exporter` Deployment.
#
# Static stdlib-only binary, so the runtime stage is `scratch`. Unlike
# tradfri-ctl it does need a CA bundle: this one dials Bambu's cloud broker
# (us.mqtt.bambulab.com:8883) and verifies the chain, rather than talking to
# a hub with a self-signed cert. No tzdata — everything is UTC or relative.

# ---- build stage ----
FROM docker.io/library/golang:1.25-bookworm@sha256:ea341baa9bd5ba6784f6d7161ace70544349a6242d54d34a0fbfd2c4d51c9d58 AS build

ARG SRC_REPO=https://github.com/polarn/waybar-modules
ARG SRC_REF=3ca45abfcfa1c457ac0fbe437bea55317367127e

WORKDIR /src
RUN git clone "${SRC_REPO}" . \
 && git checkout "${SRC_REF}"
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /bambu-exporter ./cmd/bambu-exporter

# ---- runtime stage ----
FROM scratch

COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=build /bambu-exporter /bambu-exporter

# 65532 (distroless "nonroot") to match the securityContext the flux
# manifests set, so runAsNonRoot is satisfied by the image too.
USER 65532:65532
EXPOSE 8080 9090
ENTRYPOINT ["/bambu-exporter"]
