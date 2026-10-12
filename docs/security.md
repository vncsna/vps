# Security

How this repo and the servers it provisions stay safe.

## Repo hygiene

- **No secrets are ever committed.** Only `*.env.example` manifests are tracked; real values live in a secrets manager and are exported locally (see `secrets/`). `.env` and `.secrets` are gitignored.
- **History is clean.** No secret values or personal details (emails, tokens, hostnames) appear in any commit.

## Server hardening

`bootstrap/bootstrap.sh` hardens a fresh server:

- SSH: root login and password auth disabled (key-only login).
- Firewall: `ufw` enabled, SSH only.
- `fail2ban` for SSH brute-force protection.
- `unattended-upgrades` for automatic security patches.

## Secrets at rest

- Exported locally, copied to the server, stored with `0600` permissions.
- The server never talks to the secrets manager.

## Service exposure

- Services bind to `127.0.0.1` only.
- Public access (where needed) goes through a Cloudflare Tunnel gated by Cloudflare Access (email OTP).

## Reporting a vulnerability

Use GitHub's private vulnerability reporting (Security tab) or open a private issue.
