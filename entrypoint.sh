#!/bin/bash
set -e

# Clean up stale X lock if container was restarted
rm -f /tmp/.X99-lock

# Ensure bind-mounted chromium profile dir is writable by the node user
chown -R node:node /home/node/.config/chromium

# Allow the node user to write to container stdout/stderr (for supervisord log redirection)
chmod 666 /dev/stdout /dev/stderr 2>/dev/null || true

# Drop privileges and run supervisord as the node user
exec gosu node /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
