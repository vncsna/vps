# Coddy

A general-purpose agent in a single Go binary, self-hosted on the VPS. Runs as a
systemd daemon; the web UI (installable PWA) and REST API are reached over an SSH
tunnel.

Coddy is **not** sandboxed: tools and commands run as the service user, with
permission prompts (each new session starts in `ask` mode). Unlike
[agenvoy](../agenvoy/), it does not fence execution with `bwrap`.

## Prerequisites

- [Setup](../../setup/README.md) done.
- [Secrets exported and copied over](../../secrets/README.md).
- A Bitwarden item `vps/coddy` with custom fields:
  - `OPENROUTER_API_KEY` — currently the same key agenvoy uses.

## Install

```bash
projects/coddy/install.sh
```

Downloads the pinned `1.3.70` release for this machine's architecture, verifies
it against the release `SHA256SUMS`, and installs `/usr/local/bin/coddy`.

## Configure

```bash
projects/coddy/configure.sh
```

Installs [config.yaml](config.yaml) to `~/.coddy/config.yaml` (mode 0600), creates
`~/Coddy` as the workspace, and validates the file with `coddy -t`. The
OpenRouter provider and both models are already in the config; the API key is
read from `~/.config/coddy/.secrets`.

## Run as a service

```bash
sed "s/<user>/$USER/g" projects/coddy/systemd/coddy.service \
  | sudo tee /etc/systemd/system/coddy.service
sudo systemctl daemon-reload
sudo systemctl enable --now coddy
```

The unit names the user in three paths; the `sed` above fills all of them.

`coddy serve` runs in the foreground and lets systemd own the process. Do not use
`coddy serve install` here — it writes a *user* unit, which needs
`loginctl enable-linger` to survive logout.

## Web UI

The dashboard and API listen on `127.0.0.1:12345`. Use the SSH tunnel:

```bash
projects/coddy/tunnel.sh <user>@<host>
# then open http://127.0.0.1:12345
```

The page is installable as a PWA (https or localhost). Serving it off loopback
means turning on `httpserver.login` (`coddy serve set-password --user <name>`)
and fronting it with TLS, see [Cloudflare Tunnel](../../docs/cloudflare-tunnel.md).

## Permissions

A new session starts in `ask` mode; the choice is kept per session. Scheduled
jobs default to `bypass` — leave the scheduler disabled unless you have decided
that unattended shell access as this user is acceptable.
