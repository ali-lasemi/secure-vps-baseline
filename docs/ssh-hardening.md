# SSH Hardening

Production-oriented SSH security recommendations.

---

# Objectives

- Disable root login
- Disable password authentication
- Enforce SSH keys
- Reduce brute-force attack surface

---

# Recommended Settings

## Disable Root Login

```conf
PermitRootLogin no
```

## Disable Password Authentication

```conf
PasswordAuthentication no
```

## Enable Public Keys

```conf
PubkeyAuthentication yes
```

## Limit Authentication Attempts

```conf
MaxAuthTries 3
```

---

# Verify Configuration

```bash
sudo sshd -t
```

---

# Restart SSH

```bash
sudo systemctl restart ssh
```

---

# Notes

Always verify SSH access from another terminal before closing the current session.