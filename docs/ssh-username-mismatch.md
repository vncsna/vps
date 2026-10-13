# SSH access confusion after setup

## What happened

After running `setup.sh`, SSH access appeared to be lost. Root login was
disabled and attempts to log in as the expected user failed, so it looked like
a lockout.

## Root cause

The setup was run with a custom username, not the one the SSH config expected.
The custom user had a working `authorized_keys` the whole time, but the SSH
config still pointed at `root` (disabled by hardening), and the expected user
was never created. The "lockout" was a username mismatch, not a broken key
handoff.

## Impact

Temporary confusion and an unnecessary rescue-system detour. No actual loss of
access — the custom user was reachable throughout.

## Fix

Point the SSH config at the real user and use the correct key.

## Prevention

- The username in `setup.sh` is now passed explicitly, so the docs and scripts
  agree.
- `setup.sh` also fails loudly before hardening if there is no key to hand
  off, guarding against a real lockout if root's `authorized_keys` is empty.
