# Cloudflare Tunnel

Exposes a project's local dashboard/API on a public URL, gated by Cloudflare Access so only you can reach it. The tunnel runs on the server and makes an outbound connection to Cloudflare — no inbound ports, no firewall changes, no public IP exposure.

## How it works

- **Cloudflare Tunnel** (`cloudflared`) maps a hostname (e.g. `agent.example.com`) to a local service (`http://127.0.0.1:17989`).
- **Cloudflare Access** sits in front of that hostname. Anyone hitting the URL gets a login page first (email OTP by default), and only identities you allow get through.

One tunnel can serve several projects: the ingress list maps one hostname per local service, and each hostname gets its own Access application.

Because `cloudflared` connects from `127.0.0.1`, the service's `localhostOnly` checks still pass, and the web UI + API are same-origin so CORS is not an issue.

## Prerequisites

- A Cloudflare account (free tier is enough).
- A domain on Cloudflare (the tunnel hostname lives under it).
- A scoped API token with these permissions:
  - Account → Cloudflare Tunnel: Edit
  - Account → Access: Apps and Policies: Edit
  - Zone → DNS: Edit

## Setup

1. Create the tunnel and note its ID and token:

   ```bash
   curl -X POST "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/cfd_tunnel" \
     -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
     -d '{"name":"<project>","config_src":"cloudflare"}'
   ```

2. Point the hostname at the tunnel (proxied CNAME):

   ```bash
   curl -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
     -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
     -d '{"type":"CNAME","name":"<subdomain>","content":"<tunnel-id>.cfargotunnel.com","proxied":true}'
   ```

3. Set the ingress route (hostname → local service):

   ```bash
   curl -X PUT "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/cfd_tunnel/$TUNNEL_ID/configurations" \
     -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
     -d '{"config":{"ingress":[{"hostname":"<hostname>","service":"http://127.0.0.1:<port>"},{"service":"http_status:404"}]}}'
   ```

4. Create the Access application and an allow policy for your email:

   ```bash
   APP_ID=$(curl -s -X POST "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/access/apps" \
     -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
     -d '{"name":"<project>","domain":"<hostname>","type":"self_hosted","session_duration":"24h"}' | jq -r .result.id)

   curl -X POST "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/access/apps/$APP_ID/policies" \
     -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
     -d '{"name":"Allow me","decision":"allow","include":[{"email":{"email":"<your-email>"}}]}'
   ```

5. Install `cloudflared` on the server and run it as a systemd service. Store the tunnel credentials in `/etc/cloudflared/<project>.json` (the `credentials_file` object from step 1) and use a unit like:

   ```ini
   [Unit]
   Description=Cloudflare Tunnel (<project>)
   After=network-online.target
   Wants=network-online.target

   [Service]
   Type=simple
   ExecStart=/usr/local/bin/cloudflared tunnel --no-autoupdate --credentials-file /etc/cloudflared/<project>.json run <tunnel-id>
   Restart=on-failure
   RestartSec=5

   [Install]
   WantedBy=multi-user.target
   ```

## PWAs behind Access

A browser installs a site as an app only if it can read the web app manifest. Chrome
fetches the manifest and its icons **without cookies**, so Access answers with the
login page and the browser sees HTML where it expected JSON — the install option
never appears. The app is fine; the gate is in the way.

Fix it with one more Access application per asset, each carrying a **Bypass** policy
for everyone, so only those files are public:

| Path | Why |
|---|---|
| `/manifest.webmanifest` | fetched without credentials |
| every icon the manifest lists | install icons, also fetched by the WebAPK minter |
| `/apple-touch-icon.png` | iOS home-screen icon |

```bash
curl -X POST "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/access/apps" \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"name":"<project> pwa","domain":"<hostname>/manifest.webmanifest","type":"self_hosted","session_duration":"24h","app_launcher_visible":false}'

curl -X POST "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/access/apps/$APP_ID/policies" \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"name":"Public PWA asset","decision":"bypass","include":[{"everyone":{}}]}'
```

Access matches the path **exactly**, not as a prefix: a prefix like `/icon-` matches
nothing, so every icon needs its own application. Keep the list to static shell
assets — never bypass an API route or a page that renders data. Verify with an
anonymous request; it should return the asset, while the app root still redirects
to the login page.

If the app controls its own HTML, adding `crossorigin="use-credentials"` to the
manifest `<link>` also works, since the browser then sends the Access cookie.

## Rotating the API token

The token is only used for the one-time setup above; `cloudflared` authenticates with its own tunnel credentials, not the API token. Revoke or rotate the API token freely after setup.
