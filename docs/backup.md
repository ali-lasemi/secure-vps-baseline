# Backup Strategy

Backups are a critical part of production server security and recovery planning.

---

## Backup Goals

- Recover from accidental changes
- Recover from failed deployments
- Preserve critical configuration
- Reduce operational risk

---

## Example Backup Script

```bash
BACKUP_SOURCE=/etc BACKUP_DIR=/opt/backups ./scripts/backup-server.sh
```

---

## Recommended Backup Targets

- `/etc`
- application config directories
- database dumps
- reverse proxy configs
- deployment scripts

---

## Production Notes

- Store backups outside the server
- Encrypt sensitive backups
- Test restore procedures
- Define retention policies