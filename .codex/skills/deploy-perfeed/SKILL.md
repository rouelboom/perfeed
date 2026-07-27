---
name: deploy-perfeed
description: Deploy the Perfeed Astro static site from /Users/pavel/Dev/pets/perfeed to its isolated nginx site on port 18081 of the existing server 138.16.161.115. Use when the user asks to deploy, redeploy, publish, upload, refresh, roll back, or diagnose the production Perfeed website. Builds dist/, uploads only /var/www/perfeed, configures only the perfeed nginx site and port, and verifies HTTP or HTTPS without changing d6-oracle-web.
---

# Deploy Perfeed

Deploy this Astro static site only after the user has explicitly approved the production deployment in the current task. Do not infer that permission from a request to build, preview, or prepare the site.

## Target

- project: `/Users/pavel/Dev/pets/perfeed`
- server: `root@138.16.161.115`
- remote site root: `/var/www/perfeed`
- nginx site: `/etc/nginx/sites-available/perfeed`
- backup directory: `/var/www/perfeed-backups`
- public URL: `http://138.16.161.115:18081`

Keep `d6-oracle-web` intact: never write to `/var/www/d6-oracle-web`, alter its nginx configuration, or disable the default nginx site as part of this skill.

## Service isolation

- nginx is shared infrastructure for all web projects on this server. Never start, stop, enable, disable, restart, or reinstall it as part of a Perfeed deployment.
- The deployment may run only after confirming that nginx is already active and `nginx -t` succeeds. If it is inactive or failed, stop and report the condition instead of attempting recovery.
- Never write to, restart, stop, disable, reconfigure, or inspect secrets from Xray, its rootless Podman containers, or another project's service units.
- Do not change listeners on `80`, `443`, or another project's ports. Perfeed owns only its static files in `/var/www/perfeed` and its existing nginx virtual host on `18081`.
- When a shared-infrastructure conflict is detected, create no workaround service for Perfeed. Report the conflict and request explicit user direction.

Until a domain is chosen, Perfeed uses the isolated public port `18081`. Astro dev and preview also use `18081`, so local URLs are `http://localhost:18081`. The default server name and verification URL point to the server IP and that port.

## Deploy

1. Confirm that the user has approved production deployment and that the local production preview has been checked.
2. Confirm that nginx is active and that the existing Perfeed site is the only target of the operation.
3. Run the bundled script from the repository root:

```bash
.codex/skills/deploy-perfeed/scripts/deploy.sh
```

For a future domain and HTTPS, override `PERFEED_SERVER_NAME`, `PERFEED_SITE_URL`, and optionally `PERFEED_PORT`; configure DNS and TLS first. Do not claim HTTPS works until a certificate and redirect are configured separately.

The script runs `npm run build`, requires `dist/index.html`, backs up the previous Perfeed files, syncs only `dist/` to the Perfeed directory, validates and reloads nginx, opens `18081/tcp` in active UFW, and checks the URL. It uses `rsync --delete` only inside `/var/www/perfeed`.

## Rollback and diagnosis

Each deploy saves the previous site archive in `/var/www/perfeed-backups`. To roll back, first list the archives, then restore exactly the user-selected archive into `/var/www/perfeed`, validate nginx, reload it, and verify the URL. Ask for explicit approval before the restore because it changes production content.

If verification fails, inspect `nginx -t`, `systemctl status nginx`, UFW status, DNS, the certificate, and `curl -I` for the canonical URL. Do not change the d6-oracle site while diagnosing Perfeed.

## Resource

- `scripts/deploy.sh` — repeatable production deployment with guarded parameters.
