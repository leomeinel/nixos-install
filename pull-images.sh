#!/usr/bin/env bash
###
# File: pull-images.sh
# Author: Leopold Meinel (leo@meinel.dev)
# -----
# Copyright (c) 2025 Leopold Meinel & contributors
# SPDX ID: MIT
# URL: https://opensource.org/licenses/MIT
# -----
###

# Fail on error
set -e

# Define functions
checked_cd() {
    cd "${1:?}" ||
        {
            log_err "Could not 'cd' into '${1:?}'"
            exit 1
        }
}

# Set $SCRIPT_DIR
SCRIPT_DIR="$(dirname -- "$(readlink -f -- "${0}")")"
checked_cd "${SCRIPT_DIR}"

# Get images from ${SCRIPT_DIR}/nixos/configs/virtualisation.nix and pull
IMAGES="$(grep 'image = ".*";$' ./nixos/configs/virtualisation.nix | sed 's/image = "//' | sed 's/";$//' | tr -d "[:blank:]" | sort -u)"
for image in ${IMAGES}; do
    podman image pull "${image}"
done
