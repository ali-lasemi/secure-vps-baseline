#!/usr/bin/env bash
set -Eeuo pipefail

# Safe SSH hardening for Debian/Ubuntu servers.
#
# Backs up the active sshd configuration, applies conservative hardening
# (key-only authentication, no root login, no password login), validates
# with `sshd -t`, and rolls back automatically if validation fails.
# The SSH port is never changed, and no forwarding restrictions are added.
#
# Usage:
#   sudo ./scripts/secure-ssh.sh
#
# Overridable defaults:
#   SSHD_CONFIG=/etc/ssh/sshd_config   path to the main sshd config
#   SKIP_KEY_CHECK=0                   set to 1 to skip the authorized_keys safety check

SSHD_CONFIG="${SSHD_CONFIG:-/etc/ssh/sshd_config}"
SKIP_KEY_CHECK="${SKIP_KEY_CHECK:-0}"

DROPIN_DIR="/etc/ssh/sshd_config.d"
DROPIN_FILE="$DROPIN_DIR/99-hardening.conf"
TIMESTAMP="$(date +%Y%m%d%H%M%S)"
BACKUP_FILE="${SSHD_CONFIG}.bak.${TIMESTAMP}"
DROPIN_BACKUP=""
MODE=""

HARDENING_SETTINGS=(
  "PermitRootLogin no"
  "PasswordAuthentication no"
  "PubkeyAuthentication yes"
  "PermitEmptyPasswords no"
  "MaxAuthTries 3"
  "LoginGraceTime 30"
  "ClientAliveInterval 300"
  "ClientAliveCountMax 2"
  "X11Forwarding no"
)

log()  { echo "[secure-ssh] $*"; }
fail() { echo "[secure-ssh] ERROR: $*" >&2; exit 1; }

require_root() {
  [[ "$(id -u)" -eq 0 ]] || fail "must run as root (try: sudo $0)"
}

check_environment() {
  command -v sshd >/dev/null 2>&1 || fail "sshd not found — install openssh-server first"
  command -v systemctl >/dev/null 2>&1 || fail "systemctl not found — only systemd-based Debian/Ubuntu is supported"
  [[ -f "$SSHD_CONFIG" ]] || fail "sshd config not found at $SSHD_CONFIG (override with SSHD_CONFIG=/path)"
}

warn_user() {
  log "WARNING: keep this SSH session open until you have confirmed that a NEW connection works."
  log "This script disables SSH password authentication and root login."
}

check_authorized_keys() {
  if compgen -G "/root/.ssh/authorized_keys" >/dev/null || compgen -G "/home/*/.ssh/authorized_keys" >/dev/null; then
    return
  fi
  if [[ "$SKIP_KEY_CHECK" = "1" ]]; then
    log "WARNING: no authorized_keys found under /root or /home — continuing because SKIP_KEY_CHECK=1"
    return
  fi
  fail "no authorized_keys found under /root or /home. Disabling password authentication now would lock you out. Add an SSH key first, or re-run with SKIP_KEY_CHECK=1 if your keys live elsewhere."
}

backup_config() {
  cp -a "$SSHD_CONFIG" "$BACKUP_FILE"
  log "current configuration backed up to $BACKUP_FILE"
}

decide_mode() {
  if [[ -d "$DROPIN_DIR" ]] && grep -Eq '^[[:space:]]*Include[[:space:]].*sshd_config\.d' "$SSHD_CONFIG"; then
    MODE="dropin"
  else
    MODE="inline"
  fi
}

apply_dropin() {
  if [[ -f "$DROPIN_FILE" ]]; then
    DROPIN_BACKUP="${DROPIN_FILE}.bak.${TIMESTAMP}"
    cp -a "$DROPIN_FILE" "$DROPIN_BACKUP"
    log "existing drop-in backed up to $DROPIN_BACKUP"
  fi
  {
    echo "# Written by secure-vps-baseline scripts/secure-ssh.sh"
    printf '%s\n' "${HARDENING_SETTINGS[@]}"
  } >"$DROPIN_FILE"
  chmod 0644 "$DROPIN_FILE"
  log "hardening settings written to $DROPIN_FILE"
}

apply_inline() {
  # Appended settings would land inside a Match block if one existed;
  # configs without sshd_config.d support normally do not use them.
  local setting key value
  for setting in "${HARDENING_SETTINGS[@]}"; do
    key="${setting%% *}"
    value="${setting#* }"
    if grep -Eq "^[#[:space:]]*${key}([[:space:]]|\$)" "$SSHD_CONFIG"; then
      sed -E -i "s|^[#[:space:]]*${key}([[:space:]].*)?\$|${key} ${value}|" "$SSHD_CONFIG"
    else
      printf '%s %s\n' "$key" "$value" >>"$SSHD_CONFIG"
    fi
  done
  log "hardening settings applied to $SSHD_CONFIG"
}

rollback() {
  if [[ "$MODE" = "dropin" ]]; then
    if [[ -n "$DROPIN_BACKUP" ]]; then
      cp -a "$DROPIN_BACKUP" "$DROPIN_FILE"
    else
      rm -f "$DROPIN_FILE"
    fi
  else
    cp -a "$BACKUP_FILE" "$SSHD_CONFIG"
  fi
  log "previous configuration restored"
}

validate_or_rollback() {
  if sshd -t; then
    log "configuration validated with sshd -t"
    return
  fi
  log "sshd -t failed — rolling back"
  rollback
  if sshd -t; then
    fail "hardening rolled back after failed validation; the SSH service was NOT restarted (backup: $BACKUP_FILE)"
  fi
  fail "configuration still invalid after rollback — restore manually from $BACKUP_FILE"
}

restart_ssh() {
  if systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null; then
    log "SSH service restarted"
  else
    fail "could not restart the SSH service — check 'systemctl status ssh'"
  fi
}

show_effective_settings() {
  log "effective settings reported by sshd -T:"
  sshd -T 2>/dev/null | grep -E '^(permitrootlogin|passwordauthentication|pubkeyauthentication|permitemptypasswords|maxauthtries|logingracetime|clientaliveinterval|clientalivecountmax|x11forwarding) ' || true
}

main() {
  require_root
  check_environment
  warn_user
  check_authorized_keys
  backup_config
  decide_mode
  if [[ "$MODE" = "dropin" ]]; then
    apply_dropin
  else
    apply_inline
  fi
  validate_or_rollback
  restart_ssh
  show_effective_settings
  log "done — open a NEW terminal and confirm SSH login works before closing this session"
}

main "$@"
