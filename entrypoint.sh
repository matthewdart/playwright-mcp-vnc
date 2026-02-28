#!/bin/bash
set -e

# Clean up stale X lock if container was restarted
rm -f /tmp/.X99-lock

# Ensure bind-mounted chromium profile dir is writable by the node user
chown -R node:node /home/node/.config/chromium

# Drop privileges and run supervisord as the node user
exec gosu node /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
