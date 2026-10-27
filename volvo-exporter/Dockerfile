# volvo-exporter from polarn/waybar-modules, for the flux volvo-exporter Deployment.

FROM docker.io/library/golang:1.25-bookworm@sha256:ea341baa9bd5ba6784f6d7161ace70544349a6242d54d34a0fbfd2c4d51c9d58 AS build

ARG SRC_REPO=https://github.com/polarn/waybar-modules
ARG SRC_REF=14542392686c504e7f90f7fd6c87eb9ad457b7dd

WORKDIR /src
RUN git clone "${SRC_REPO}" . \
 && git checkout "${SRC_REF}"
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /volvo-exporter ./cmd/volvo-exporter

FROM scratch

COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=build /volvo-exporter /volvo-exporter

USER 65532:65532
EXPOSE 8080 9090
ENTRYPOINT ["/volvo-exporter"]
