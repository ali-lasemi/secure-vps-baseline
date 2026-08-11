#!/usr/bin/env bash

set -uo pipefail

VERSION="1.0.0"

SCORE=100

PASS=0
FAIL=0
WARN=0

pass() {
    echo "[PASS] $1"
    PASS=$((PASS+1))
}

warn() {
    echo "[WARN] $1"
    WARN=$((WARN+1))
    SCORE=$((SCORE-5))
}

fail() {
    echo "[FAIL] $1"
    FAIL=$((FAIL+1))
    SCORE=$((SCORE-10))
}

section() {
    echo
    echo "=============================="
    echo "$1"
    echo "=============================="
}

check_ssh() {

    section "SSH"

    if command -v sshd >/dev/null 2>&1; then

        ROOT=$(sshd -T 2>/dev/null | awk '/permitrootlogin/ {print $2}')
        PASSAUTH=$(sshd -T 2>/dev/null | awk '/passwordauthentication/ {print $2}')

        if [[ "$ROOT" == "no" ]]; then
    pass "Root login disabled"
else
    fail "Root login enabled"
fi

        if [[ "$PASSAUTH" == "no" ]]; then
    pass "Password authentication disabled"
else
    warn "Password authentication enabled"
fi

    else
        warn "sshd unavailable"
    fi
}

check_firewall() {

    section "Firewall"

    if command -v ufw >/dev/null 2>&1; then

        if ufw status | grep -q active; then
    pass "UFW active"
else
    fail "UFW inactive"
fi

    else
        warn "UFW missing"
    fi
}

check_fail2ban() {

    section "Fail2Ban"

    if systemctl is-active --quiet fail2ban; then
        pass "Fail2Ban active"
    else
        warn "Fail2Ban inactive"
    fi
}

check_updates() {

    section "Updates"

    if command -v apt-get >/dev/null 2>&1; then

        UPDATES=$(apt-get -s upgrade 2>/dev/null | grep -c "^Inst")

        if [[ "$UPDATES" -eq 0 ]]; then
    pass "No pending updates"
else
    warn "$UPDATES pending updates"
fi

    else
        warn "APT unavailable"
    fi
}

main() {

    echo "Secure VPS Security Score v$VERSION"

    check_ssh
    check_firewall
    check_fail2ban
    check_updates

    [[ "$SCORE" -lt 0 ]] && SCORE=0

    echo
    echo "=============================="
    echo "Security Score: $SCORE/100"
    echo "Passed: $PASS"
    echo "Warnings: $WARN"
    echo "Failed: $FAIL"
    echo "=============================="
}

main "$@"