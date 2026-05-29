#!/usr/bin/env bash
set -Eeuo pipefail

sudo ufw default deny incoming
sudo ufw default allow outgoing

sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

sudo ufw --force enable

sudo ufw status verbose