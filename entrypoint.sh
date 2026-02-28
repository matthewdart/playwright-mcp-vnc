#!/bin/bash
set -e

# Clean up stale X lock if container was restarted
rm -f /tmp/.X99-lock

exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
