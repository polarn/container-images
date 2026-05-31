# opnsense-mcp — vespo92/OPNSenseMCP packaged as a streamable-HTTP MCP server.
#
# Upstream ships only as a stdio npm package with a broken Dockerfile. This builds
# it multi-stage (slim, non-root) and pins the upstream commit for reproducibility
# and supply-chain safety. Runs standalone — no postgres/redis (ENABLE_CACHING=false).

# ---- build stage ----
FROM node:24-alpine@sha256:2bdb65ed1dab192432bc31c95f94155ca5ad7fc1392fb7eb7526ab682fa5bf14 AS build

ARG SRC_REPO=https://github.com/vespo92/OPNSenseMCP
ARG SRC_REF=fc93c9e883bbe19d9ae264a96c1dbe6668c6ea75

# git: clone source; python3/make/g++: native modules (ssh2, pg)
RUN apk add --no-cache git python3 make g++
WORKDIR /app
RUN git clone "${SRC_REPO}" . \
 && git checkout "${SRC_REF}" \
 && npm ci \
 && npx tsc \
 && npm prune --omit=dev \
 && npm cache clean --force

# ---- runtime stage ----
FROM node:24-alpine@sha256:2bdb65ed1dab192432bc31c95f94155ca5ad7fc1392fb7eb7526ab682fa5bf14

WORKDIR /app
COPY --from=build /app/dist ./dist
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/package.json ./package.json

# Connection + transport are supplied at runtime by the k8s Deployment;
# these are sane defaults so the image is usable as-is.
ENV MCP_TRANSPORT=streamable-http \
    MCP_SSE_HOST=0.0.0.0 \
    MCP_SSE_PORT=3000 \
    ENABLE_CACHING=false

USER node
EXPOSE 3000
CMD ["node", "dist/index.js"]
