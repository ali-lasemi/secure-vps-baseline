# UFW Rules

## Default Policies

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
```

## SSH

```bash
sudo ufw allow 22/tcp
```

## HTTP

```bash
sudo ufw allow 80/tcp
```

## HTTPS

```bash
sudo ufw allow 443/tcp
```

## Enable Firewall

```bash
sudo ufw enable
```

## Status

```bash
sudo ufw status verbose
```