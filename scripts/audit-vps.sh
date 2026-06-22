#!/usr/bin/env bash
set -Eeuo pipefail

PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0

pass() {
  echo "[PASS] $1"
  PASS_COUNT=$((PASS_COUNT + 1))
}

fail() {
  echo "[FAIL] $1"
  FAIL_COUNT=$((FAIL_COUNT + 1))
}

warn() {
  echo "[WARN] $1"
  WARN_COUNT=$((WARN_COUNT + 1))
}

echo "Secure VPS Baseline Audit"
echo "========================="
echo

echo "Checking SSH configuration..."

SSHD_CONFIG="/etc/ssh/sshd_config"

if [[ -f "$SSHD_CONFIG" ]]; then
  grep -Eq "^PermitRootLogin\s+no" "$SSHD_CONFIG" && pass "Root SSH login disabled" || fail "Root SSH login is not explicitly disabled"
  grep -Eq "^PasswordAuthentication\s+no" "$SSHD_CONFIG" && pass "Password authentication disabled" || fail "Password authentication is not explicitly disabled"
  grep -Eq "^PubkeyAuthentication\s+yes" "$SSHD_CONFIG" && pass "Public key authentication enabled" || warn "Public key authentication is not explicitly enabled"
else
  warn "sshd_config not found"
fi

echo
echo "Checking firewall..."

if command -v ufw >/dev/null 2>&1; then
  if sudo ufw status | grep -q "Status: active"; then
    pass "UFW firewall is active"
  else
    fail "UFW firewall is not active"
  fi
else
  warn "UFW is not installed"
fi

echo
echo "Checking Fail2Ban..."

if systemctl is-active --quiet fail2ban; then
  pass "Fail2Ban is active"
else
  fail "Fail2Ban is not active"
fi

echo
echo "Checking automatic updates..."

if dpkg -l | grep -q unattended-upgrades; then
  pass "unattended-upgrades package installed"
else
  warn "unattended-upgrades is not installed"
fi

echo
echo "Audit Summary"
echo "-------------"
echo "Passed: $PASS_COUNT"
echo "Warnings: $WARN_COUNT"
echo "Failed: $FAIL_COUNT"

if [[ "$FAIL_COUNT" -gt 0 ]]; then
  exit 1
fi