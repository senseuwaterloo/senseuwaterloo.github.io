#!/usr/bin/env bash
#
# Install the senseuw-site template units and enable an instance.
# Idempotent; run as root on the server.
#
# The site deploys pull-based: senseuw-site@SITE.timer polls the repo's main
# every 2 minutes and, on new commits, rebuilds the checkout at
# /usr/local/src/SITE into /var/www/SITE (served by Caddy). The instance
# name after '@' supplies both paths via %i. No deploy credentials exist
# anywhere. See homepage issue #7.
#
# Usage: install.sh [SITE]   (default: senseuw)
#
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
SITE="${1:-senseuw}"

[ "$(id -u)" -eq 0 ] || { echo "run as root" >&2; exit 1; }
id infra >/dev/null 2>&1 || { echo "missing 'infra' user" >&2; exit 1; }
[ -d "/usr/local/src/$SITE/.git" ] || { echo "missing checkout at /usr/local/src/$SITE" >&2; exit 1; }
for cmd in git npm npx; do
  [ -x "/usr/bin/$cmd" ] || { echo "/usr/bin/$cmd not found (units use absolute paths)" >&2; exit 1; }
done

install -d -o infra -g infra "/var/www/$SITE"
install -m 644 "$HERE/senseuw-site@.service" "$HERE/senseuw-site@.timer" /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now "senseuw-site@$SITE.timer"
systemctl start "senseuw-site@$SITE"   # build now rather than waiting a tick

cat <<EOF
Installed. Useful commands:
  systemctl list-timers 'senseuw-site@*'      # next/last poll
  systemctl status senseuw-site@$SITE         # last run result
  journalctl -u senseuw-site@$SITE            # build/deploy log
  systemctl start senseuw-site@$SITE          # force an immediate deploy

If an old site-pull or crontab deploy line exists in a crontab, remove it: crontab -e -u infra
EOF
