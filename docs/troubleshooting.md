# Troubleshooting

Practical recovery steps for problems caused by the hardening in this repository.

---

# SSH Lockout

If a new SSH connection is refused or times out:

- Do **not** close any SSH session that is still open — use it to fix the problem.
- If no session is open, log in through your provider's web console (see the last section); it does not go through SSH.

Check the service:

```bash
sudo systemctl status ssh
```

Check recent authentication failures:

```bash
sudo journalctl -u ssh -n 50
```

Common causes: password authentication disabled without a working key, the firewall blocking the SSH port, or a Fail2Ban ban on your IP.

---

# Invalid sshd Configuration

Test the configuration before restarting the service:

```bash
sudo sshd -t
```

The output names the file and line with the error. Fix it, re-run `sshd -t`, and only then restart:

```bash
sudo systemctl restart ssh
```

A running SSH service keeps serving existing sessions even when the config on disk is broken — never restart it while `sshd -t` fails.

---

# Restoring SSH Configuration from Backup

`scripts/secure-ssh.sh` creates a timestamped backup before making changes:

```bash
ls /etc/ssh/sshd_config.bak.*
```

Restore it:

```bash
sudo cp /etc/ssh/sshd_config.bak.<timestamp> /etc/ssh/sshd_config
```

If the script wrote a drop-in instead, remove it:

```bash
sudo rm /etc/ssh/sshd_config.d/99-hardening.conf
```

Then validate and restart:

```bash
sudo sshd -t
```

```bash
sudo systemctl restart ssh
```

---

# UFW Lockout

From the provider console:

```bash
sudo ufw status verbose
```

Allow SSH again:

```bash
sudo ufw allow 22/tcp
```

If you use a nonstandard SSH port, allow that port instead. As a last resort, disable the firewall temporarily while you fix the rules:

```bash
sudo ufw disable
```

Re-enable it as soon as the SSH rule is in place.

---

# Fail2Ban: Unban an IP

List currently banned addresses:

```bash
sudo fail2ban-client status sshd
```

Unban your address:

```bash
sudo fail2ban-client set sshd unbanip <IP>
```

Re-run the status command to confirm the ban is gone.

---

# Checking Logs

SSH authentication attempts:

```bash
sudo journalctl -u ssh -n 100
```

```bash
sudo tail -100 /var/log/auth.log
```

Fail2Ban activity:

```bash
sudo tail -100 /var/log/fail2ban.log
```

Firewall blocks (when UFW logging is enabled):

```bash
sudo tail -100 /var/log/ufw.log
```

---

# Provider Console and Rescue Mode

When SSH access is lost entirely:

- Every major VPS provider offers a **web console** (VNC or serial) in its control panel that logs you in without SSH. Use it to fix firewall rules, restore the SSH config, or unban your IP as described above.
- Console login requires a password. If all password logins are disabled, boot into the provider's **rescue mode**: it starts a temporary system with your VPS disk attached.
- In rescue mode, mount the root filesystem (the provider documents the device name), then edit the configuration on the mounted disk, e.g. `/mnt/etc/ssh/sshd_config`, or remove `/mnt/etc/ssh/sshd_config.d/99-hardening.conf`.
- Reboot back into the normal system and verify SSH access before closing the console.
