# Firewall Hardening

UFW provides a simple and effective firewall management layer.

---

## Security Model

Default strategy:

```txt
Deny Incoming
Allow Outgoing
Explicitly Allow Required Services
```

---

## Common Rules

### SSH

```bash
sudo ufw allow 22/tcp
```

### HTTP

```bash
sudo ufw allow 80/tcp
```

### HTTPS

```bash
sudo ufw allow 443/tcp
```

---

## Verify

```bash
sudo ufw status verbose
```

---

## Notes

Only expose services that are required.

Avoid opening database ports directly to the internet.