# SSH access confusion after setup

## What happened

After running `setup.sh`, SSH access appeared to be lost. Root login was
disabled and attempts to log in as `deploy` failed, so it looked like a lockout.

## Root cause

The setup was run with the username `<user>`, not the script's default
`deploy`. The `<user>` user had a working `authorized_keys` the whole time, but
the SSH config still pointed at `root` (disabled by hardening), and `deploy`
was never created. The "lockout" was a username mismatch, not a broken key
handoff.

## Impact

Temporary confusion and an unnecessary rescue-system detour. No actual loss of
access — `<user>` was reachable throughout.

## Fix

Point the SSH config at the real user (`<user>`) and use the correct key.

## Prevention

- The default username in `setup.sh` now matches the one actually used
  (`<user>`), so the docs and scripts agree.
- `setup.sh` also fails loudly before hardening if there is no key to hand
  off, guarding against a real lockout if root's `authorized_keys` is empty.
