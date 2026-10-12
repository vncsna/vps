# Agenvoy

A personal knowledge-management agent, self-hosted on the VPS. Runs 24/7 as a systemd daemon, reachable via Telegram (day-to-day) and an SSH tunnel to the web dashboard (maintenance).

## Prerequisites

- [Bootstrap](../../bootstrap/README.md) done.
- [Secrets exported and copied over](../../secrets/README.md).
- A Bitwarden item `vps/agenvoy` with custom fields:
  - `OPENROUTER_API_KEY` — your OpenRouter key.
  - `TELEGRAM_TOKEN` — a bot token from [@BotFather](https://t.me/BotFather).
  - `GITHUB_TOKEN` — a fine-grained PAT scoped to the notes repo.
  - `OPENAI_API_KEY` (optional) — enables semantic search embeddings.
- An OpenRouter account and a chosen model (e.g. `anthropic/claude-sonnet-4.5`).
- A private `notes` repo on GitHub (the agent's knowledge base).

## Install

```bash
projects/agenvoy/install.sh
```

Installs the `agen` binary and its dependencies (`bwrap`, `pdftotext`, etc.).

## Configure

```bash
projects/agenvoy/configure.sh <openrouter-model> <notes-repo-url>
```

This registers the OpenRouter model, enables the Telegram bot, and (if a notes repo URL is given) bootstraps the notes repo. It expects the secrets to already be in `~/.config/agenvoy/.secrets` (exported locally and copied over). The daemon must be running (see below) for the model/channel calls to succeed.

## Notes repo

The agent's knowledge lives in a private git repo, cloned to `~/repos/notes/`. `setup-notes.sh` creates the workspace, clones the repo, seeds `profile.md` from the template, and configures git push auth via `GITHUB_TOKEN`. Edit `~/repos/notes/profile.md` with your details after setup.

## Persona

`persona.md` is the agent's role — it tells the agent how to save notes, maintain `profile.md`, and commit + push. Apply it to a session (the Telegram session is the one you use day-to-day):

```bash
projects/agenvoy/set-persona.sh            # lists sessions
projects/agenvoy/set-persona.sh <session-id>
```

Message the bot once first so its session exists.

## Run as a service

```bash
sudo cp projects/agenvoy/systemd/agenvoy.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now agenvoy
```

Edit the `User=` line in the unit to match the user whose `~/.config/agenvoy` holds the config.

## Telegram verification

The first time you message the bot, Agenvoy sends a 6-digit code. It needs an admin channel to relay it to:

```bash
curl -X POST http://127.0.0.1:17989/v1/channel/admin \
  -H 'Content-Type: application/json' \
  -d '{"value":"tg@<your-chat-id>"}'
```

Then message the bot, read the code from the relay, and reply with it. Authorized chat IDs are stored in `~/.config/agenvoy/.telegram`.

## Dashboard

The dashboard and REST API listen on `127.0.0.1:17989`. They are exposed publicly at a hostname of your choosing via Cloudflare Tunnel, gated by Cloudflare Access (email OTP) so only you can reach it. See [Cloudflare Tunnel](../../docs/cloudflare-tunnel.md).

SSH tunnel remains a fallback:

```bash
projects/agenvoy/tunnel.sh <user>@<host>
# then open http://127.0.0.1:17989
```

## Knowledge management

The agent captures notes into the notes repo (searched with its built-in file search), keeps stable facts in `profile.md`, and remembers past conversations via its built-in memory. Start by asking it to capture notes; it builds its own tools and memory as you go. See the [Agenvoy docs](https://agenvoy.com/docs/) for the full feature set.

Long-document RAG (papers, PDFs) is deferred — [PageIndex](https://github.com/VectifyAI/PageIndex) is a candidate for that later.
