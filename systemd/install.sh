#!/usr/bin/env bash
#
# Install the site-pull template units and enable an instance.
# Idempotent; run as root on the server.
#
# The site deploys pull-based: site-pull@SITE.timer polls the repo's main
# every 2 minutes and, on new commits, rebuilds the checkout at
# /usr/local/src/SITE into /var/www/SITE (served by Caddy). The instance
# name after '@' supplies both paths via %i. No deploy credentials exist
# anywhere. See homepage issue #7.
#
# Usage: install.sh [SITE]   (default: senseuwaterloo)
#
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
SITE="${1:-senseuwaterloo}"

[ "$(id -u)" -eq 0 ] || { echo "run as root" >&2; exit 1; }
id infra >/dev/null 2>&1 || { echo "missing 'infra' user" >&2; exit 1; }
[ -d "/usr/local/src/$SITE/.git" ] || { echo "missing checkout at /usr/local/src/$SITE" >&2; exit 1; }
for cmd in git npm npx; do
  [ -x "/usr/bin/$cmd" ] || { echo "/usr/bin/$cmd not found (units use absolute paths)" >&2; exit 1; }
done

install -d -o infra -g infra "/var/www/$SITE"
install -m 644 "$HERE/site-pull@.service" "$HERE/site-pull@.timer" /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now "site-pull@$SITE.timer"
systemctl start "site-pull@$SITE"   # build now rather than waiting a tick

cat <<EOF
Installed. Useful commands:
  systemctl list-timers 'site-pull@*'      # next/last poll
  systemctl status site-pull@$SITE         # last run result
  journalctl -u site-pull@$SITE            # build/deploy log
  systemctl start site-pull@$SITE          # force an immediate deploy

If an old site-pull line exists in a crontab, remove it: crontab -e -u infra
EOF
