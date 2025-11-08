#!/usr/bin/env bash
###
# File: dhparams.sh
# Author: Leopold Meinel (leo@meinel.dev)
# -----
# Copyright (c) 2025 Leopold Meinel & contributors
# SPDX ID: GPL-3.0-or-later
# URL: https://www.gnu.org/licenses/gpl-3.0-standalone.html
# -----
###

# Fail on error
set -e

# Print certs to stdout
echo "Printing 'dhparams.pem' to stdout"
openssl dhparam -out /dev/stdout 4096
