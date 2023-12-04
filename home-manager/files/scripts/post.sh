#!/usr/bin/env bash
###
# File: post.sh
# Author: Leopold Meinel (leo@meinel.dev)
# -----
# Copyright (c) 2023 Leopold Meinel & contributors
# SPDX ID: GPL-3.0-or-later
# URL: https://www.gnu.org/licenses/gpl-3.0-standalone.html
# -----
###

# FIXME: This file shouldn't have to exist and limits reproducibility

# Set $SCRIPT_DIR
SCRIPT_DIR="$(dirname -- "$(readlink -f -- "$0")")"

# Fail on error
set -e

# Generate usbguard allow-policy for connected devices
doas sh -c 'usbguard generate-policy >/var/lib/usbguard/rules.conf'

# Remove script
rm -f "$SCRIPT_DIR"/post.sh
