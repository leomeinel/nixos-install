#!/usr/bin/env bash
###
# File: update.sh
# Author: Leopold Johannes Meinel (leo@meinel.dev)
# -----
# Copyright (c) 2025 Leopold Johannes Meinel & contributors
# SPDX ID: Apache-2.0
# URL: https://www.apache.org/licenses/LICENSE-2.0
###

# Set ${SCRIPT_DIR}
SCRIPT_DIR="$(dirname -- "$(readlink -f -- "${0}")")"
cd "${SCRIPT_DIR}"

# Fail on error
set -e

# Set DATE
DATE="$(date +"%FT%H-%M-%S")"

# Update lock file
cd "${SCRIPT_DIR}"
nix flake update

# Update current NixOS system
nixos-rebuild boot --flake "${SCRIPT_DIR}"
git add .
git commit -m "System update: ${DATE}"
