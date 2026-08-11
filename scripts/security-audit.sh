#!/usr/bin/env bash

set -uo pipefail

VERSION="2.0.0"

PASS_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0
INFO_COUNT=0

SCORE=100

pass() {
    echo "[PASS] $1"
    PASS_COUNT=$((PASS_COUNT+1))
}

warn() {
    echo "[WARN] $1"
    WARN_COUNT=$((WARN_COUNT+1))
    SCORE=$((SCORE-3))
}

fail() {
    echo "[FAIL] $1"
    FAIL_COUNT=$((FAIL_COUNT+1))
    SCORE=$((SCORE-10))
}

info() {
    echo "[INFO] $1"
    INFO_COUNT=$((INFO_COUNT+1))
}

section() {
    echo
    echo "================================"
    echo "$1"
    echo "================================"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

check_ssh() {

section "SSH Security"

if ! command_exists sshd; then
    warn "sshd command not available"
    return
fi


ROOT_LOGIN=$(sshd -T 2>/dev/null | awk '/permitrootlogin/ {print $2}')
PASSWORD_AUTH=$(sshd -T 2>/dev/null | awk '/passwordauthentication/ {print $2}')
PUBKEY_AUTH=$(sshd -T 2>/dev/null | awk '/pubkeyauthentication/ {print $2}')
PORT=$(sshd -T 2>/dev/null | awk '/port/ {print $2}')


if [[ "$ROOT_LOGIN" == "no" ]]; then
    pass "Root SSH login disabled"
else
    fail "Root SSH login enabled: $ROOT_LOGIN"
fi


if [[ "$PASSWORD_AUTH" == "no" ]]; then
    pass "Password authentication disabled"
else
    fail "Password authentication enabled"
fi


if [[ "$PUBKEY_AUTH" == "yes" ]]; then
    pass "Public key authentication enabled"
else
    warn "Public key authentication not enabled"
fi


info "SSH port: ${PORT:-unknown}"

}


check_firewall() {

section "Firewall"

if ! command_exists ufw; then
    warn "UFW not installed"
    return
fi


if ufw status | grep -q active; then
    pass "UFW firewall active"
else
    fail "UFW firewall inactive"
fi


}


check_ports() {

section "Network Ports"

if command_exists ss; then

PORTS=$(ss -tuln | wc -l)

info "Listening sockets detected: $PORTS"

else

warn "ss command unavailable"

fi

}


check_fail2ban() {

section "Fail2Ban"

if ! command_exists fail2ban-client; then
    warn "Fail2Ban not installed"
    return
fi


if systemctl is-active --quiet fail2ban; then
    pass "Fail2Ban service active"
else
    fail "Fail2Ban service inactive"
fi

}


check_users() {

section "User Security"

if [[ -r /etc/shadow ]]; then

EMPTY=$(awk -F: '$2=="" {print $1}' /etc/shadow)

if [[ -z "$EMPTY" ]]; then

pass "No empty password users"

else

fail "Empty password users: $EMPTY"

fi

else

warn "Cannot read shadow file"

fi

}


check_updates() {

section "System Updates"


if command_exists apt-get; then

UPDATES=$(apt-get -s upgrade 2>/dev/null | grep -c "^Inst")


if [[ "$UPDATES" -eq 0 ]]; then

pass "System packages up to date"

else

warn "$UPDATES pending updates"

fi


else

warn "apt-get unavailable"

fi

}


check_services(){

section "Running Services"


if command_exists systemctl; then

COUNT=$(systemctl list-units \
--type=service \
--state=running \
--no-legend | wc -l)


info "$COUNT running services"

else

warn "systemctl unavailable"

fi

}


check_logs(){

section "SSH Failed Login Attempts"


if command_exists journalctl; then


FAILED=$(journalctl \
-u ssh \
-u sshd \
--since "24 hours ago" \
2>/dev/null |
grep -Eic "failed password|invalid user")


if [[ "$FAILED" -eq 0 ]]; then

pass "No failed SSH attempts"

else

warn "$FAILED failed SSH attempts detected"

fi


else

warn "journalctl unavailable"

fi

}


summary(){

section "Security Summary"

[[ "$SCORE" -lt 0 ]] && SCORE=0

echo "Security Score: $SCORE/100"

echo

echo "PASS: $PASS_COUNT"
echo "WARN: $WARN_COUNT"
echo "FAIL: $FAIL_COUNT"
echo "INFO: $INFO_COUNT"

echo

echo "Audit completed."
echo "No changes were made."

}


main(){

echo "Secure VPS Baseline Audit v$VERSION"

echo "Host: $(hostname)"

check_ssh
check_firewall
check_ports
check_fail2ban
check_users
check_updates
check_services
check_logs

summary

}


main "$@"

