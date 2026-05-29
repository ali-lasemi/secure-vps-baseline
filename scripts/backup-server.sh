#!/usr/bin/env bash
set -Eeuo pipefail

BACKUP_SOURCE="${BACKUP_SOURCE:-/etc}"
BACKUP_DIR="${BACKUP_DIR:-/opt/backups}"
TIMESTAMP="$(date +%Y%m%d%H%M%S)"
BACKUP_FILE="$BACKUP_DIR/server-backup-$TIMESTAMP.tar.gz"

mkdir -p "$BACKUP_DIR"

tar -czf "$BACKUP_FILE" "$BACKUP_SOURCE"

echo "Backup created: $BACKUP_FILE"