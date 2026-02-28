# Playwright MCP + noVNC

Playwright MCP server with headed Chromium, accessible via noVNC for interactive authentication flows.

## Quick start

```bash
docker compose up -d --build
```

- **noVNC**: http://localhost:6080/vnc.html
- **MCP SSE**: http://localhost:8931/sse

## MCP client config

```json
{
  "mcpServers": {
    "playwright": {
      "url": "http://localhost:8931/sse"
    }
  }
}
```

## Authentication workflow

1. Tell the agent to navigate to the target site
2. Open noVNC in your browser and enter credentials manually
3. Hand control back to the agent — cookies persist for the session

## Notes

- The `playwright-data` volume persists the Chromium profile across restarts
  so cookies/sessions survive container recreation.
- VNC has no password set (`-nopw`). Keep the noVNC port behind Tailscale,
  not exposed via Cloudflare tunnel.
- The `cli.js` path inside the container may vary between image versions.
  If the build fails, check with:
  `docker run --rm -it mcr.microsoft.com/playwright/mcp find / -name "cli.js" 2>/dev/null`

## Customisation

Adjust resolution via environment variables in `docker-compose.yml`:

```yaml
environment:
  - SCREEN_WIDTH=1920
  - SCREEN_HEIGHT=1080
```
