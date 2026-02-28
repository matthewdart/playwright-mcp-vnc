FROM mcr.microsoft.com/playwright/mcp:v0.0.68

USER root

# Install display stack: Xvfb (virtual framebuffer), x11vnc (VNC server),
# fluxbox (lightweight WM), noVNC + websockify (browser-based VNC client)
RUN apt-get update && apt-get install -y --no-install-recommends \
    xvfb \
    x11vnc \
    fluxbox \
    novnc \
    websockify \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Environment
ENV DISPLAY=:99
ENV SCREEN_WIDTH=1280
ENV SCREEN_HEIGHT=720
ENV SCREEN_DEPTH=24
ENV VNC_PORT=5900
ENV NOVNC_PORT=6080
ENV MCP_PORT=8931

# Supervisor config to manage all processes
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE ${NOVNC_PORT} ${MCP_PORT}

ENTRYPOINT ["/entrypoint.sh"]
