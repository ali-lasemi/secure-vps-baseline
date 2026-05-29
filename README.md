# Secure VPS Baseline

Production-ready VPS hardening baseline with SSH security, firewall configuration, Fail2Ban protection, system updates, logging and backup practices.

---

# Overview

This repository contains practical security hardening guidelines and automation examples for Linux VPS environments.

The goal is to establish a secure, maintainable and production-oriented server baseline.

---

# Security Areas

## SSH Hardening

- Disable password authentication
- Enforce key-based login
- Disable root login
- Restrict SSH access

## Firewall

- UFW examples
- Default deny policies
- Service-specific rules

## Fail2Ban

- SSH brute-force protection
- Custom jail examples

## System Security

- Security updates
- Package management
- Kernel parameters
- User management

## Backup & Recovery

- Backup automation
- Recovery planning
- Retention strategies

---

# Repository Structure

```txt
docs/                  Documentation and hardening guides
examples/              Example configurations
scripts/               Automation scripts
.github/workflows/     Validation workflows
```

---

# Security Principles

```txt
Least Privilege
Defense in Depth
Secure by Default
Automation
Operational Simplicity
```

---

# Included Components

- SSH hardening examples
- UFW firewall examples
- Fail2Ban examples
- System hardening examples
- Backup automation examples
- Operational documentation

---

# Roadmap

- Automated server bootstrap
- CIS-inspired hardening
- Docker host hardening
- Audit tooling
- Compliance examples
- Monitoring integration

---

# Philosophy

```txt
Security is not a product.
Security is a process.
```

---

# License

MIT License