# Playwright MCP + noVNC

Playwright MCP server with headed Chromium, accessible via noVNC for interactive authentication flows. Designed to integrate with [mcp-gateway](https://github.com/matthewdart/mcp-gateway) via Docker label-based service discovery.

## Quick start

```bash
docker compose up -d --build
```

- **noVNC**: http://localhost:6080/vnc.html
- **MCP SSE**: http://localhost:8931/sse

## Gateway integration

The container exposes Docker labels for automatic discovery by mcp-gateway's `DockerProvider`:

```yaml
labels:
  mcp.enabled: "true"
  mcp.namespace: "playwright"
  mcp.transport: "http"
  mcp.url: "http://localhost:8931/sse"
```

After the container starts, call `gateway_reload` to pick it up. Tools will appear under the `playwright` namespace.

**Note:** The explicit `mcp.url` is required because:
- The container uses `network_mode: host` (container name not DNS-resolvable)
- Playwright MCP uses legacy SSE at `/sse`, not streamable HTTP at `/mcp`

## Authentication workflow

1. Tell the agent to navigate to the target site
2. Open noVNC in your browser and enter credentials manually
3. Hand control back to the agent — cookies persist for the session

## CI/CD

Pushes to `main` trigger the GitHub Actions workflow which:
1. Builds an ARM64 image via `toolbox/build-arm-image.yml`
2. Pushes to `ghcr.io/matthewdart/playwright-mcp-vnc:latest`
3. Deploys to the Oracle VM via `toolbox/deploy-stack.yml`

## Security

- VNC has no password set (`-nopw`). **Keep the noVNC port (6080) accessible only via Tailscale** — do not expose via Cloudflare tunnel.
- The MCP SSE port (8931) is accessible to the gateway on localhost via host networking.

## Notes

- The `playwright-data` volume persists the Chromium profile across restarts so cookies/sessions survive container recreation.
- The `cli.js` path inside the container may vary between image versions. If the build fails, check with:
  `docker run --rm -it mcr.microsoft.com/playwright/mcp find / -name "cli.js" 2>/dev/null`

## Customisation

Adjust resolution via environment variables in `docker-compose.yml`:

```yaml
environment:
  - SCREEN_WIDTH=1920
  - SCREEN_HEIGHT=1080
```
