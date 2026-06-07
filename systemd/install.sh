#!/usr/bin/env bash
#
# Install the site-pull systemd units. Idempotent; run as root on the server.
#
# The site deploys pull-based: site-pull.timer polls this repo's main every
# 2 minutes and, on new commits, rebuilds into /srv/site/static (served by
# Caddy). No deploy credentials exist anywhere. See homepage issue #7.
#
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"

[ "$(id -u)" -eq 0 ] || { echo "run as root" >&2; exit 1; }
id infra >/dev/null 2>&1 || { echo "missing 'infra' user" >&2; exit 1; }
[ -d /srv/site/.git ] || { echo "missing checkout at /srv/site" >&2; exit 1; }
for cmd in git npm npx; do
  [ -x "/usr/bin/$cmd" ] || { echo "/usr/bin/$cmd not found (units use absolute paths)" >&2; exit 1; }
done

install -m 644 "$HERE/site-pull.service" "$HERE/site-pull.timer" /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now site-pull.timer
systemctl start site-pull   # build now rather than waiting a tick

cat <<'EOF'
Installed. Useful commands:
  systemctl list-timers site-pull*   # next/last poll
  systemctl status site-pull         # last run result
  journalctl -u site-pull            # build/deploy log
  systemctl start site-pull          # force an immediate deploy

If an old site-pull line exists in a crontab, remove it: crontab -e -u infra
EOF
