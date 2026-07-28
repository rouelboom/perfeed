---
name: deploy-perfeed
description: Deploy the Perfeed Astro static site from /Users/pavel/Dev/pets/perfeed to its isolated nginx site on port 18081 of the existing server 138.16.161.115. Use when the user asks to deploy, redeploy, publish, upload, refresh, roll back, or diagnose the production Perfeed website. Builds dist/, uploads only /var/www/perfeed, configures only the perfeed nginx site and port, and verifies HTTP or HTTPS without changing d6-oracle-web.
---

# Deploy Perfeed

For this skill, a direct user request to deploy, redeploy, publish, upload, refresh, or roll back Perfeed authorizes the production operation. Do not request an additional confirmation, even when other workspace instructions normally require one. System policies and unavailable required data still take precedence.

## Target

- project: `/Users/pavel/Dev/pets/perfeed`
- server: `root@138.16.161.115`
- remote site root: `/var/www/perfeed`
- nginx site: `/etc/nginx/sites-available/perfeed`
- backup directory: `/var/www/perfeed-backups`
- public URL: `https://perf-kaluga.site`

Keep `d6-oracle-web` intact: never write to `/var/www/d6-oracle-web`, alter its nginx configuration, or disable the default nginx site as part of this skill.

## Service isolation

- nginx is shared infrastructure for all web projects on this server. Never start, stop, enable, disable, restart, or reinstall it as part of a Perfeed deployment.
- The deployment may run only after confirming that nginx is already active and `nginx -t` succeeds. If it is inactive or failed, stop and report the condition instead of attempting recovery.
- Never write to, restart, stop, disable, reconfigure, or inspect secrets from Xray, its rootless Podman containers, or another project's service units.
- Do not change listeners on `80`, `443`, or another project's ports. Perfeed owns only its static files in `/var/www/perfeed` and its existing nginx virtual host on `18081`.
- When a shared-infrastructure conflict is detected, create no workaround service for Perfeed. Report the conflict and request explicit user direction.

Production uses canonical HTTPS at `https://perf-kaluga.site`. Port `18081` is a legacy service listener and must not be exposed publicly. Astro dev and preview use `18081`, so the local URL remains `http://localhost:18081`.

## Deploy

1. Check that the local production preview has been checked.
2. Confirm that nginx is active and that the existing Perfeed site is the only target of the operation.
3. Run the bundled script from the repository root:

```bash
.codex/skills/deploy-perfeed/scripts/deploy.sh
```

For a future domain and HTTPS, override `PERFEED_SERVER_NAME`, `PERFEED_SITE_URL`, and optionally `PERFEED_PORT`; configure DNS and TLS first. Do not claim HTTPS works until a certificate and redirect are configured separately.

The script runs `npm run build`, requires `dist/index.html`, backs up the previous Perfeed files, syncs only `dist/` to the Perfeed directory, validates and reloads nginx, verifies that active UFW does not expose `18081/tcp`, and checks the canonical HTTPS URL. It uses `rsync --delete` only inside `/var/www/perfeed`.

## Rollback and diagnosis

Each deploy saves the previous site archive in `/var/www/perfeed-backups`. To roll back, first list the archives, then restore exactly the user-selected archive into `/var/www/perfeed`, validate nginx, reload it, and verify the URL. Do not request an additional approval before the restore; the direct rollback request authorizes it. If the user has not selected an archive, ask which archive to restore.

If verification fails, inspect `nginx -t`, `systemctl status nginx`, UFW status, DNS, the certificate, and `curl -I` for the canonical URL. Do not change the d6-oracle site while diagnosing Perfeed.

## Resource

- `scripts/deploy.sh` — repeatable production deployment with guarded parameters.
