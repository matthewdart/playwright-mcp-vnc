# Playwright MCP + noVNC

Playwright MCP server with headed Chromium, accessible via noVNC for interactive authentication flows. Uses `--shared-browser-context` so the browser persists across MCP sessions and remains visible in VNC. Designed to integrate with [mcp-gateway](https://github.com/matthewdart/mcp-gateway) via Docker label-based service discovery.

## Quick start

The compose stack includes a Tailscale sidecar for network access. You need a Tailscale auth key:

```bash
# Create docker-compose.override.yml with your Tailscale auth key
cat > docker-compose.override.yml <<EOF
services:
  tailscale:
    environment:
      - TS_AUTHKEY=tskey-auth-...
EOF

docker compose up -d
```

- **noVNC**: http://playwright-mcp-vnc:6080/vnc.html (via Tailscale)
- **MCP endpoint**: http://127.0.0.1:8931/mcp (Streamable HTTP)

## Gateway integration

The container exposes Docker labels for automatic discovery by mcp-gateway's `DockerProvider`:

```yaml
labels:
  mcp.enabled: "true"
  mcp.namespace: "playwright"
  mcp.transport: "http"
  mcp.url: "http://127.0.0.1:8931/mcp"
```

After the container starts, call `gateway_reload` to pick it up. Tools will appear under the `playwright` namespace.

**Note:** The explicit `mcp.url` is required because the container uses `network_mode: service:tailscale` (shares the Tailscale sidecar's network namespace), so its container name is not DNS-resolvable by the gateway.

## Authentication workflow

1. Tell the agent to navigate to the target site
2. Open noVNC in your browser and enter credentials manually
3. Hand control back to the agent — cookies persist for the session

## Architecture

The container runs five processes via supervisord:

| Process | Role |
|---|---|
| **Xvfb** | Virtual framebuffer (`:99`, configurable resolution) |
| **fluxbox** | Lightweight window manager |
| **x11vnc** | VNC server on port 5900 |
| **websockify** | noVNC web client on port 6080 |
| **Playwright MCP** | MCP server on port 8931 with `--shared-browser-context` |

The Tailscale sidecar provides network access and publishes ports 6080 and 8931.

## CI/CD

Pushes to `main` trigger the GitHub Actions workflow which:
1. Builds an ARM64 image via `toolbox/build-arm-image.yml`
2. Pushes to `ghcr.io/matthewdart/playwright-mcp-vnc:latest`
3. Deploys to the Oracle VM via `toolbox/deploy-stack.yml` (injects `TS_AUTHKEY` from repo secrets)

## Security

- VNC has no password set (`-nopw`). **Keep the noVNC port (6080) accessible only via Tailscale** — do not expose via Cloudflare tunnel.
- The MCP port (8931) is restricted via `--allowed-hosts` to `localhost:8931` and `127.0.0.1:8931`.

## Notes

- Chromium profile data persists at `./data/chromium-profile/` (bind mount to `/home/pwuser/.config/chromium` inside the container). On the VM this maps to `/opt/playwright-mcp-vnc/data/chromium-profile/`. The `--user-data-dir` flag tells Playwright MCP to use this path, so cookies, localStorage, and sessions survive container restarts.
- The base image is pinned to `mcr.microsoft.com/playwright/mcp:v0.0.68`. To upgrade, check available tags at `mcr.microsoft.com/v2/playwright/mcp/tags/list`.
- The `cli.js` path inside the container (`/app/cli.js`) may change between image versions. Verify with:
  `docker run --rm mcr.microsoft.com/playwright/mcp:v0.0.68 find / -name "cli.js" 2>/dev/null`

## Customisation

Adjust resolution via environment variables in `docker-compose.yml`:

```yaml
environment:
  - SCREEN_WIDTH=1920
  - SCREEN_HEIGHT=1080
```
