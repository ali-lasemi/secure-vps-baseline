# VPS Security Audit

This document describes the VPS security audit script included in this repository.

---

## Purpose

The audit script provides a quick security baseline review for Linux VPS environments.

It checks:

- SSH hardening
- Firewall status
- Fail2Ban status
- Automatic updates

---

## Script

scripts/audit-vps.sh

---

## Usage

./scripts/audit-vps.sh

---

## Checks

### SSH

The script checks whether:

- Root login is disabled
- Password authentication is disabled
- Public key authentication is enabled

### Firewall

The script checks whether UFW is installed and active.

### Fail2Ban

The script checks whether Fail2Ban is active.

### Automatic Updates

The script checks whether unattended-upgrades is installed.

---

## Output

The script reports:

- PASS
- WARN
- FAIL

---

## Production Notes

This audit is intentionally lightweight.

It is not a replacement for a full security assessment or formal compliance scan.