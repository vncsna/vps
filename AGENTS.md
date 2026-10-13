# VPS repo conventions

This repo is the source of truth for a self-hosted VPS. The server runs a
copy of the files under `projects/`; changes here don't take effect until
they're synced over and re-applied.

- When you change anything under `projects/` (persona, scripts, systemd
  units), flag that the server needs updating and point to the sync step in
  [docs/adding-a-project.md](docs/adding-a-project.md#updating-a-project).
- Never commit secrets — only `*.env.example` manifests are tracked.
- Follow the conventions in `docs/`.
