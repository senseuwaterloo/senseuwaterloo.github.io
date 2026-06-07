# Deployment

The site deploys **pull-based**: no deploy credentials exist anywhere.

The server (`pineapple`) polls `main` every 2 minutes with a cron job
(`site-pull`). When new commits land it rebuilds the site and rsyncs the
output into the web root served by Caddy. GitHub Actions only runs the build
as a CI check — it pushes nothing and holds no secrets.

A merge to `main` is live within ~3–4 minutes. If a poll fails (GitHub down,
network blip), the next tick self-heals — there is nothing to rotate, renew,
or hand off.

## Server setup (one-time)

Requires `git`, `rsync`, and Node.js LTS on the server, plus an existing
clone of this repo (paths are set at the top of `site-pull`).

As root on the server:

```sh
# Dedicated unprivileged user — must NOT be in the docker group, and should
# own the checkout and the web root.
useradd --system --home-dir /srv/site --shell /usr/sbin/nologin deploy
chown -R deploy:deploy /srv/site

install -m 755 site-pull /usr/local/bin/site-pull
install -m 644 site-pull.cron /etc/cron.d/site-pull
```

## Operations

```sh
sudo -u deploy /usr/local/bin/site-pull   # force an immediate deploy
journalctl -t site-pull                   # deploy log (or grep syslog)
git -C /srv/site/homepage log -1          # exactly what is live
```

To roll back, revert the offending commit on `main`; the server converges on
the next tick.

Note: `npm ci` runs with `--ignore-scripts` so dependency lifecycle scripts
never execute on this host. If a future dependency genuinely needs its
install script, prefer replacing the dependency over dropping the flag.

## History

The previous push-based deploy (GitHub Actions joining the Headscale tailnet
and rsyncing over SSH) broke when its pre-auth key expired and was removed;
see issue #7. The pull model was chosen because it needs no expiring
credentials and survives lab member turnover.
