#!/usr/bin/env bash
set -Eeuo pipefail

# Installs and configures Fail2Ban on Debian/Ubuntu servers.
#
# Installs the package only if missing, deploys the repository example
# jail configuration to /etc/fail2ban/jail.local (backing up any existing
# file), validates it, then enables and starts the service.
#
# Usage:
#   sudo ./scripts/install-fail2ban.sh
#
# Overridable defaults:
#   JAIL_EXAMPLE=<path>   jail config to deploy (defaults to the repo example)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JAIL_EXAMPLE="${JAIL_EXAMPLE:-$SCRIPT_DIR/../examples/fail2ban/jail.local.example}"
JAIL_LOCAL="/etc/fail2ban/jail.local"
TIMESTAMP="$(date +%Y%m%d%H%M%S)"
BACKUP_FILE=""

log()  { echo "[install-fail2ban] $*"; }
fail() { echo "[install-fail2ban] ERROR: $*" >&2; exit 1; }

require_root() {
  [[ "$(id -u)" -eq 0 ]] || fail "must run as root (try: sudo $0)"
}

check_environment() {
  command -v apt-get >/dev/null 2>&1 || fail "apt-get not found — only Debian/Ubuntu is supported"
  command -v systemctl >/dev/null 2>&1 || fail "systemctl not found — only systemd-based Debian/Ubuntu is supported"
  [[ -f "$JAIL_EXAMPLE" ]] || fail "jail example not found at $JAIL_EXAMPLE"
}

install_package() {
  if command -v fail2ban-server >/dev/null 2>&1; then
    log "Fail2Ban is already installed — skipping installation"
    return
  fi
  log "installing Fail2Ban"
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y fail2ban
}

deploy_config() {
  if [[ -f "$JAIL_LOCAL" ]]; then
    BACKUP_FILE="${JAIL_LOCAL}.bak.${TIMESTAMP}"
    cp -a "$JAIL_LOCAL" "$BACKUP_FILE"
    log "existing jail.local backed up to $BACKUP_FILE"
  fi
  install -m 0644 "$JAIL_EXAMPLE" "$JAIL_LOCAL"
  log "deployed $JAIL_EXAMPLE to $JAIL_LOCAL"
}

rollback() {
  if [[ -n "$BACKUP_FILE" ]]; then
    cp -a "$BACKUP_FILE" "$JAIL_LOCAL"
    log "previous jail.local restored"
  else
    rm -f "$JAIL_LOCAL"
    log "deployed jail.local removed"
  fi
}

validate_or_rollback() {
  if fail2ban-client -t >/dev/null; then
    log "configuration validated with fail2ban-client -t"
    return
  fi
  log "configuration test failed — rolling back"
  rollback
  fail "deployed configuration was invalid and has been rolled back; the service was not restarted"
}

enable_and_start() {
  systemctl enable fail2ban >/dev/null 2>&1 || fail "could not enable the fail2ban service"
  systemctl restart fail2ban || fail "could not start fail2ban — check 'journalctl -u fail2ban'"
  log "Fail2Ban enabled and started"
}

show_status() {
  local attempt
  for attempt in 1 2 3 4 5; do
    fail2ban-client status >/dev/null 2>&1 && break
    [[ "$attempt" -lt 5 ]] || fail "Fail2Ban did not respond after start — check 'systemctl status fail2ban'"
    sleep 1
  done
  log "service state: $(systemctl is-active fail2ban)"
  fail2ban-client status
  fail2ban-client status sshd || fail "the sshd jail is not active — check /var/log/fail2ban.log"
}

main() {
  require_root
  check_environment
  install_package
  deploy_config
  validate_or_rollback
  enable_and_start
  show_status
  log "done"
}

main "$@"
