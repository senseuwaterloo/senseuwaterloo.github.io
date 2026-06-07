#!/usr/bin/env bash
#
# Place the systemd declarations and enable a site instance. Run as root.
# Assumes nothing of the host beyond systemd (plus git/node on the search
# path, resolved by systemd itself at service start).
#
# Usage: install.sh [SITE]   (default: senseuw)
#
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
SITE="${1:-senseuw}"

install -m 644 "$HERE/senseuw-site@.service" "$HERE/senseuw-site@.timer" /etc/systemd/system/
install -m 644 "$HERE/senseuw-site.sysusers" /etc/sysusers.d/senseuw-site.conf
systemd-sysusers
install -d -m 700 /etc/credstore
install -d -o senseuw-site -g senseuw-site "/var/www/$SITE"
systemctl daemon-reload
systemctl enable --now "senseuw-site@$SITE.timer"

cat <<EOF
Declarations installed; senseuw-site@$SITE.timer enabled.

One-time provisioning (secrets/data — deliberately not in this repo):

  1. Deploy key (read-only):
       ssh-keygen -t ed25519 -N '' -C "senseuw-site@$SITE" -f /etc/credstore/$SITE-deploy-key
       chmod 600 /etc/credstore/$SITE-deploy-key
     Register the .pub as a read-only deploy key on the GitHub repo
     (Settings -> Deploy keys).

  2. Checkout:
       GIT_SSH_COMMAND="ssh -i /etc/credstore/$SITE-deploy-key -o IdentitiesOnly=yes" \\
         git clone git@github.com:senseuwaterloo/homepage.git /usr/local/src/$SITE
       chown -R senseuw-site:senseuw-site /usr/local/src/$SITE

  3. First build:  systemctl start senseuw-site@$SITE

Useful commands:
  systemctl status senseuw-site@$SITE          # last run result
  journalctl -u senseuw-site@$SITE             # build/deploy log
  systemctl list-timers 'senseuw-site@*'       # polling status
EOF
