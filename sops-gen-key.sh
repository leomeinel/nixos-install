#!/usr/bin/env bash
###
# File: sops-gen-key.sh
# Author: Leopold Johannes Meinel (leo@meinel.dev)
# -----
# Copyright (c) 2025 Leopold Johannes Meinel & contributors
# SPDX ID: Apache-2.0
# URL: https://www.apache.org/licenses/LICENSE-2.0
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
