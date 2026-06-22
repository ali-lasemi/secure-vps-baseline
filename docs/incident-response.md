# Incident Response Checklist

This document provides a basic incident response checklist for VPS environments.

---

## Purpose

The goal is to provide a repeatable process for responding to security incidents.

Examples:

- Brute-force attacks
- Unauthorized access attempts
- Suspicious processes
- Service compromise
- Malware activity

---

## Initial Response

### 1. Identify the Incident

Determine:

- What happened
- When it happened
- Which services are affected
- Whether customer impact exists

---

### 2. Preserve Evidence

Do not immediately delete logs.

Collect:

```bash
journalctl -xe
```

```bash
last -a
```

```bash
lastb
```

```bash
sudo cat /var/log/auth.log
```

---

### 3. Check Active Sessions

```bash
who
```

```bash
w
```

```bash
ss -tulpn
```

---

## SSH Security Incident

If suspicious login activity is detected:

### Review Logs

```bash
sudo grep "Failed password" /var/log/auth.log
```

```bash
sudo grep "Accepted" /var/log/auth.log
```

### Immediate Actions

- Change credentials if required
- Rotate SSH keys
- Disable compromised accounts
- Verify sudo users

---

## Service Compromise

### Check Running Processes

```bash
ps aux
```

### Check Open Ports

```bash
ss -tulpn
```

### Check Recent Changes

```bash
find /etc -mtime -7
```

```bash
find /home -mtime -7
```

---

## Containment

Possible actions:

- Block attacker IPs
- Disable compromised accounts
- Stop affected services
- Restrict network access

---

## Recovery

After containment:

- Restore clean configuration
- Apply security updates
- Verify backups
- Re-enable services
- Monitor logs closely

---

## Post-Incident Review

Document:

- Timeline
- Root cause
- Impact
- Recovery actions
- Preventive measures

---

## Recommended Follow-Up

- Review SSH configuration
- Review firewall rules
- Review Fail2Ban status
- Review user accounts
- Run VPS security audit
- Update documentation