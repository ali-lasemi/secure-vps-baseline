# System Hardening

Production-oriented operating system security recommendations.

---

# Security Updates

Update packages regularly:

```bash
sudo apt update
sudo apt upgrade -y
```

---

# Unattended Upgrades

Install:

```bash
sudo apt install unattended-upgrades -y
```

Enable:

```bash
sudo dpkg-reconfigure unattended-upgrades
```

---

# Kernel Hardening

Example sysctl configuration:

```bash
sudo cp examples/system/sysctl-hardening.conf /etc/sysctl.d/99-hardening.conf
```

Apply:

```bash
sudo sysctl --system
```

---

# Recommendations

- Keep packages updated
- Remove unused services
- Disable unnecessary ports
- Monitor logs
- Backup regularly