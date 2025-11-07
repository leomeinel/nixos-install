#!/usr/bin/env bash
###
# File: sops-gen-key.sh
# Author: Leopold Meinel (leo@meinel.dev)
# -----
# Copyright (c) 2025 Leopold Meinel & contributors
# SPDX ID: MIT
# URL: https://opensource.org/licenses/MIT
# -----
###

# Fail on error
set -e

# Generate host key with age-keygen
OUTPUT_DIR=~/.local/share/age/keys
mkdir -p "${OUTPUT_DIR}"
chmod 0700 "${OUTPUT_DIR}"
OUTPUT="${OUTPUT_DIR}"/nixos-install.txt
nix-shell -p age --run "age-keygen -o ${OUTPUT}"
chmod 0400 "${OUTPUT}"
