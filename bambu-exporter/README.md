# bambu-exporter

Prometheus exporter for a Bambu Lab printer, built from
[polarn/waybar-modules](https://github.com/polarn/waybar-modules)
(`cmd/bambu-exporter`). Deployed by the flux `bambu-exporter` app.

## Why it is a daemon rather than a scrape-time fetch

The printer rate-limits `pushall` to roughly one request a minute, so nothing
can query the cloud per scrape. The exporter holds a single MQTT subscription
open instead and lives off the partial `push_status` messages the printer
streams unprompted — measured at one every 1–2 seconds — so any number of
consumers can read as often as they like at no cost to the printer.

## Ports

| Port | Path | For |
|------|------|-----|
| 9090 | `/metrics` | Prometheus text, ~43 `bambulab_*` gauges. Cluster-internal. |
| 8080 | `/state` | The merged report as JSON, for the waybar pill. On the LAN ingress. |
| 8080 | `/healthz` | Process liveness. Deliberately not tied to report freshness — a powered-off printer is not an unhealthy exporter. |

## Configuration

Environment only, to suit `envFrom: secretRef`:

| Variable | Default | Notes |
|----------|---------|-------|
| `BAMBU_SESSION_JSON` | — | Contents of `~/.config/bambu-cloud.json`. Falls back to `BAMBU_SESSION_PATH` / the file on disk for local runs. |
| `BAMBU_SERIAL` | from the session | |
| `BAMBU_PRINTER_NAME` | from the session | Becomes the `printer_name` label. |
| `BAMBU_METRICS_ADDR` | `:9090` | |
| `BAMBU_HTTP_ADDR` | `:8080` | |

The cloud token lasts about three months and can only be renewed
interactively (`bambu-ctl login`), so the pod will need a rotated secret
roughly quarterly. Watch `bambulab_cloud_auth_ok` and
`bambulab_cloud_token_age_seconds` rather than waiting to notice a gap in the
graphs.

## Base image

`scratch`, like `tradfri-ctl`, but with the CA bundle copied from the builder:
this binary verifies TLS against Bambu's cloud broker rather than talking to a
hub with a self-signed cert. Result is ~6.7 MB.

## Building locally

```bash
podman build -t localhost/bambu-exporter:test .
podman run --rm -p 9090:9090 \
  -e BAMBU_SESSION_JSON="$(cat ~/.config/bambu-cloud.json)" \
  localhost/bambu-exporter:test
```

Give it a couple of seconds before scraping: the listener is up immediately,
but printer-sourced metrics only appear once the first report has merged.
That is intentional — a metric the printer has not reported is absent rather
than a confidently wrong zero.

`SRC_REF` pins the waybar-modules commit; bump it to ship a new build.
