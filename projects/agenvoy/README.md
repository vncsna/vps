# Agenvoy

A personal knowledge-management agent, self-hosted on the VPS. Runs 24/7 as a systemd daemon, reachable via Telegram (day-to-day) and an SSH tunnel to the web dashboard (maintenance).

## Prerequisites

- [Bootstrap](../../bootstrap/README.md) done.
- [Bitwarden CLI logged in](../../secrets/README.md).
- A Bitwarden item `vps/agenvoy` with custom fields:
  - `OPENROUTER_API_KEY` — your OpenRouter key.
  - `TELEGRAM_TOKEN` — a bot token from [@BotFather](https://t.me/BotFather).
  - `OPENAI_API_KEY` (optional) — enables semantic search embeddings.
- An OpenRouter account and a chosen model (e.g. `anthropic/claude-sonnet-4.5`).

## Install

```bash
projects/agenvoy/install.sh
```

Installs the `agen` binary and its dependencies (`bwrap`, `pdftotext`, etc.).

## Configure

```bash
projects/agenvoy/configure.sh <openrouter-model>
```

This syncs secrets from Bitwarden into `~/.config/agenvoy/.secrets`, registers the OpenRouter model, and enables the Telegram bot. The daemon must be running (see below) for the model/channel calls to succeed.

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

## Dashboard (maintenance)

The dashboard and REST API listen on `127.0.0.1:17989`. Reach them over SSH:

```bash
projects/agenvoy/tunnel.sh <user>@<host>
# then open http://127.0.0.1:17989
```

## Knowledge management

Agenvoy ships with long-term memory, file search, RAG (KuraDB), skills, and a scheduler. Start by asking it to capture notes; it builds its own tools and memory as you go. See the [Agenvoy docs](https://agenvoy.com/docs/) for the full feature set.
