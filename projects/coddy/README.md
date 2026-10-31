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
  - `GITHUB_TOKEN` — a fine-grained PAT scoped to the repos Coddy may read and
    write (`Contents: read/write`, `Metadata: read`), used for git clone/push.

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

Installs [config.yaml](config.yaml) to `~/.coddy/config.yaml` (mode 0600) and
[AGENTS.md](AGENTS.md) to `~/.coddy/AGENTS.md`, creates `~/coddy` as the
workspace, validates the config with `coddy -t`, and wires up git auth. The
OpenRouter provider and both models are already in the config; the API key is
read from `~/.config/coddy/.secrets`.

## Instructions

[AGENTS.md](AGENTS.md) is Coddy's standing persona. The agent home copy is read
in every session, whatever workspace it runs in; workspace and nested
`AGENTS.md` files add to it, so a cloned repo can carry its own conventions.
It also carries agenvoy's knowledge workflow: notes in `~/repos/notes/`,
`profile.md`, commit and push, and search notes first.

## GitHub access

`configure.sh` installs `GITHUB_TOKEN` into git's credential helper and creates
`~/coddy/repos/`. Clone repos there and commit/push as usual.

Git keeps one HTTPS credential per `github.com`, and agenvoy already configured
one. Use the same PAT for both agents (scope it to the notes repo plus whatever
Coddy needs); a different token here replaces agenvoy's entry and its pushes
stop working. If the two need separate tokens, configure a per-repo credential
helper instead of the global one.

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

The dashboard and API listen on `127.0.0.1:12345`, exposed at a hostname of your
choosing through the Cloudflare Tunnel and gated by Cloudflare Access (email OTP),
like agenvoy. See [Cloudflare Tunnel](../../docs/cloudflare-tunnel.md).

`httpserver.allow_insecure` is on because the tunnel sends the public `Host`
name to a loopback listener; without it Coddy answers `421`.

The page is installable as a PWA. The tunnel hostname is https, so install and
notifications work there.

SSH tunnel remains a fallback:

```bash
projects/coddy/tunnel.sh <user>@<host>
# then open http://127.0.0.1:12345
```

## Permissions

A new session starts in `ask` mode; the choice is kept per session. Scheduled
jobs default to `bypass` — leave the scheduler disabled unless you have decided
that unattended shell access as this user is acceptable.

The unit sets `NoNewPrivileges=yes`, so the agent cannot use the account's
passwordless sudo even if a tool call tries to. Anything that needs root has to
be run by hand outside the service.
