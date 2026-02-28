#!/bin/sh
# Restore dumpable flag after supervisord's setuid() drops privileges.
# Without this, Chrome's crashpad handler fails because setuid() sets
# dumpable=0, preventing the crash handler from using ptrace.
python3 -c "import ctypes; ctypes.CDLL(None).prctl(4, 1, 0, 0, 0)" 2>/dev/null || true
exec node /app/cli.js "$@"
