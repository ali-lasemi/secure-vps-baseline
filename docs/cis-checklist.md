# CIS-Inspired VPS Hardening Checklist

This checklist is inspired by common Linux hardening practices and CIS recommendations.

Note: This repository does not claim CIS compliance.

---

## SSH Security

- [ ] Disable root SSH login
- [ ] Disable password authentication
- [ ] Enable public key authentication
- [ ] Change default SSH port (optional)
- [ ] Restrict SSH access with firewall rules

---

## User Management

- [ ] Create a dedicated administrative user
- [ ] Disable unused accounts
- [ ] Use sudo instead of direct root access
- [ ] Review user accounts regularly

---

## Firewall

- [ ] Enable UFW
- [ ] Allow only required ports
- [ ] Deny all unnecessary inbound traffic
- [ ] Review firewall rules periodically

---

## Fail2Ban

- [ ] Install Fail2Ban
- [ ] Protect SSH service
- [ ] Review ban logs regularly

---

## Updates

- [ ] Enable automatic security updates
- [ ] Apply critical patches promptly
- [ ] Remove unused packages

---

## Logging

- [ ] Verify system logging is enabled
- [ ] Review authentication logs
- [ ] Monitor failed login attempts

---

## Backups

- [ ] Configure automated backups
- [ ] Verify backup integrity
- [ ] Store backups off-server

---

## Monitoring

- [ ] Monitor CPU and memory usage
- [ ] Monitor disk usage
- [ ] Monitor service availability

---

## Security Review

- [ ] Run audit script
- [ ] Review firewall configuration
- [ ] Review SSH configuration
- [ ] Review installed services