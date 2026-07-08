# opnsense-mcp — coreyhines/opnsense-mcp packaged as a streamable-HTTP MCP server.
#
# Replaces the earlier vespo92/OPNSenseMCP build: that server's ssh_* tools crash
# the whole process on any SSH failure (unhandled 'error' emit, still present at
# HEAD) and its DHCP tooling only queries the legacy ISC backend — dead weight on
# a dnsmasq-based OPNsense. This upstream is dnsmasq-aware (mk_dhcp_host & co,
# mutations dry-run by default) and serves streamable-http natively via FastMCP —
# a maintained reference implementation, not a stdio bridge, so the
# supergateway/mcp-proxy session bugs that pushed opnsense onto the in-process
# bundle pattern don't apply here.
#
# API-only config (OPNSENSE_FIREWALL_HOST / OPNSENSE_API_KEY / OPNSENSE_API_SECRET);
# the optional SSH toolset goes unused, so no openssh-client in the runtime image.

# ---- build stage ----
FROM docker.io/library/python:3.12-slim-bookworm@sha256:8a7e7cc04fd3e2bd787f7f24e22d5d119aa590d429b50c95dfe12b3abe52f48b AS build

ARG SRC_REPO=https://github.com/coreyhines/opnsense-mcp
ARG SRC_REF=c29211910cb430bbe8a6d0ebebadae12c57f499a

RUN apt-get update && apt-get install -y --no-install-recommends git ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# deps resolve from upstream's committed uv.lock, so the set is reproducible
RUN pip install --no-cache-dir uv==0.11.28

# pin uv to the base image's interpreter: upstream's .python-version wants
# 3.12.0 exactly, which makes uv fetch a managed CPython and symlink the venv
# to a path that doesn't exist in the runtime stage; any 3.12 satisfies
# requires-python, and this path is identical in both stages
ENV UV_PYTHON=/usr/local/bin/python3.12

WORKDIR /app
RUN git clone "${SRC_REPO}" . \
 && git checkout "${SRC_REF}" \
 && uv sync --frozen --no-dev --no-install-project

# ---- runtime stage ----
FROM docker.io/library/python:3.12-slim-bookworm@sha256:8a7e7cc04fd3e2bd787f7f24e22d5d119aa590d429b50c95dfe12b3abe52f48b

WORKDIR /app
COPY --from=build /app/.venv ./.venv
COPY --from=build /app/opnsense_mcp ./opnsense_mcp
COPY --from=build /app/main.py ./

# HOME=/tmp: startup probes ~/.opnsense-env dotfiles; nobody has no home
ENV PATH="/app/.venv/bin:$PATH" \
    PYTHONPATH=/app \
    PYTHONUNBUFFERED=1 \
    HOME=/tmp

USER 65534:65534
EXPOSE 8765

CMD ["python", "main.py", "--transport", "streamable-http", "--host", "0.0.0.0", "--port", "8765"]
