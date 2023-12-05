#!/usr/bin/env bash
###
# File: update.sh
# Author: Leopold Meinel (leo@meinel.dev)
# -----
# Copyright (c) 2023 Leopold Meinel & contributors
# SPDX ID: GPL-3.0-or-later
# URL: https://www.gnu.org/licenses/gpl-3.0-standalone.html
# -----
###

# Set $SCRIPT_DIR
SCRIPT_DIR="$(dirname -- "$(readlink -f -- "$0")")"

# Fail on error
set -e

# Set DATE
DATE="$(date +"%F-%H")"

# Backup flake.lock
if [[ -f /etc/nixos/flake.nix ]] && [[ ! -f "$SCRIPT_DIR"/flake.lock ]]; then
    rsync --exclude ".git" /etc/nixos/nixos-install/ "$SCRIPT_DIR"/ &&
        doas rm -rf /etc/nixos/*
    git add .
    git commit -m "Copy repo from /etc/nixos/nixos-install/"
fi

if [[ -f "$SCRIPT_DIR"/flake.lock ]]; then
    mkdir -p "$SCRIPT_DIR"/versions/"$DATE"
    mv "$SCRIPT_DIR"/flake.lock "$SCRIPT_DIR"/versions/"$DATE"
else
    echo "ERROR: $SCRIPT_DIR/flake.lock doesn't exist. Aborting update."
    exit
fi

# Update current NixOS system
doas nixos-rebuild switch --flake "$SCRIPT_DIR"/#red
git add .
git commit -m "Rebuild system"
