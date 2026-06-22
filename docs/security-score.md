# VPS Security Scoring Model

This document defines a simple security scoring model for VPS environments.

---

## Purpose

The scoring model helps evaluate the overall hardening level of a server.

The score is intended for operational review and educational purposes.

---

## Scoring Categories

### SSH Security

Maximum Score: 25

| Check | Score |
|---------|---------|
| Root login disabled | 10 |
| Password authentication disabled | 10 |
| Public key authentication enabled | 5 |

---

### Firewall

Maximum Score: 20

| Check | Score |
|---------|---------|
| UFW installed | 10 |
| UFW active | 10 |

---

### Fail2Ban

Maximum Score: 15

| Check | Score |
|---------|---------|
| Fail2Ban installed | 5 |
| Fail2Ban active | 10 |

---

### Updates

Maximum Score: 15

| Check | Score |
|---------|---------|
| unattended-upgrades installed | 5 |
| automatic updates enabled | 10 |

---

### Backups

Maximum Score: 15

| Check | Score |
|---------|---------|
| Backup configured | 5 |
| Backup verified | 10 |

---

### Monitoring

Maximum Score: 10

| Check | Score |
|---------|---------|
| Monitoring configured | 5 |
| Health checks configured | 5 |

---

## Score Interpretation

| Score | Rating |
|---------|---------|
| 90 - 100 | Excellent |
| 75 - 89 | Good |
| 60 - 74 | Acceptable |
| 40 - 59 | Needs Improvement |
| Below 40 | High Risk |

---

## Example

SSH Security: 25

Firewall: 20

Fail2Ban: 15

Updates: 10

Backups: 10

Monitoring: 10

Total Score:

90 / 100

Rating:

Excellent

---

## Notes

This scoring model is intentionally simple.

It is designed to demonstrate operational security practices rather than provide formal compliance certification.