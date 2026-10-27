# volvo-exporter

Prometheus exporter for one Volvo car, built from
[polarn/waybar-modules](https://github.com/polarn/waybar-modules)
(`cmd/volvo-exporter`). Deployed by the flux `volvo-exporter` app.

## One token holder

Volvo's refresh token is single-use and rotates on every refresh (access tokens
last 5 minutes). Two processes holding copies of `tokens.json` spend each
other's tokens and end in a browser login, so the exporter is the only holder:
it keeps `tokens.json` in `$VOLVO_DATA_DIR`, and the waybar pill reads its
`/state` instead of calling the API. Run one replica with `strategy: Recreate`
so two pods never overlap.

## Ports

| Port | Path | For |
|------|------|-----|
| 9090 | `/metrics` | Prometheus text, `volvo_*` families. Location is not exported. |
| 8080 | `/state` | Last snapshot as JSON (`volvo.ExporterState`), for `volvo-ctl` with `VOLVO_EXPORTER_URL`. 503 until the first good poll. |
| 8080 | `/healthz` | Process liveness. |
| 20999 | `/auth`, `/callback` | Browser login, on `127.0.0.1` only. |

## Configuration

| Variable | Default | Notes |
|----------|---------|-------|
| `VOLVO_CONFIG_JSON` | — | Contents of `~/.config/volvo/config.json`. `vin` and `redirect_uri` are required. |
| `VOLVO_DATA_DIR` | `/data` | Holds `tokens.json` and its lock. Must be writable by 65532. |
| `VOLVO_INTERVAL` | `5m` | At least `1m`. Each poll is 10 API calls against a 10,000/day app quota. |
| `VOLVO_METRICS_ADDR` | `:9090` | |
| `VOLVO_HTTP_ADDR` | `:8080` | |

## Login

The first start, or a lapsed grant (`volvo_auth_ok 0`), needs a browser login:

```bash
kubectl -n volvo-exporter port-forward deploy/volvo-exporter 20999
```

Then open `http://localhost:20999/auth`. Volvo redirects to the GitHub Pages
forwarder in `redirect_uri`, which sends the browser on to
`localhost:20999/callback`, through the port-forward and into the pod.

## Building locally

```bash
podman build -t localhost/volvo-exporter:test .
podman run --rm -p 9090:9090 -p 8080:8080 -v "$PWD/data:/data:U" \
  -e VOLVO_CONFIG_JSON="$(cat ~/.config/volvo/config.json)" \
  localhost/volvo-exporter:test
```

Start from an empty `data/` and log in through `/auth`; never copy in
`~/.config/volvo/tokens.json`, because a copy is a second holder.

`SRC_REF` pins the waybar-modules commit; bump it to ship a new build.
