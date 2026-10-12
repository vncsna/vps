# SSH lockout after setup

## What happened

After running `setup.sh`, SSH access to the server was lost. Root login was
disabled and the `deploy` user rejected every available key, so no one could
log in over SSH.

## Root cause

`setup.sh` copied root's `authorized_keys` to the new user *conditionally* —
only if the file existed — and then unconditionally disabled root and password
login. When root's `authorized_keys` was empty (the key wasn't present at setup
time), the copy produced an empty `authorized_keys` for the new user, and the
hardening then locked out all SSH access.

## Impact

No SSH access to the server. The server itself stayed up (services kept
running), but it could only be reached via the provider's out-of-band console.

## Fix

From the provider console, append a valid public key to the new user's
`authorized_keys`:

```bash
mkdir -p /home/deploy/.ssh
echo '<public-key>' >> /home/deploy/.ssh/authorized_keys
chown -R deploy:deploy /home/deploy/.ssh
chmod 700 /home/deploy/.ssh && chmod 600 /home/deploy/.ssh/authorized_keys
```

## Prevention

`setup.sh` now fails loudly before hardening if there is no key to hand off,
and verifies the copy landed before disabling root login.
