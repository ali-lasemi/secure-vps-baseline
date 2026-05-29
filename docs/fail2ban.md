# Fail2Ban

Fail2Ban helps protect Linux servers from brute-force attacks.

---

## Install

```bash
sudo apt update
sudo apt install fail2ban -y
```

---

## Example Jail

```ini
[sshd]
enabled = true
port = ssh
filter = sshd
maxretry = 3
```

---

## Commands

```bash
sudo systemctl enable fail2ban
sudo systemctl restart fail2ban
sudo fail2ban-client status
sudo fail2ban-client status sshd
```

---

## Notes

Fail2Ban should be used together with SSH key authentication and firewall rules.