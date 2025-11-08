#!/usr/bin/env sh
###
# File: certs.sh
# Author: Leopold Meinel (leo@meinel.dev)
# -----
# Copyright (c) 2025 Leopold Meinel & contributors
# SPDX ID: MIT
# URL: https://opensource.org/licenses/MIT
# -----
###

# Fail on error
set -e

# Install dependencies
apk add --no-cache openssl

# Create directories
CERT_DIR=/certs
rm -f "${CERT_DIR}"/* || true
mkdir -p "${CERT_DIR}"

# Server key/cert
openssl req -x509 -newkey ec -pkeyopt ec_paramgen_curve:secp521r1 -days 3650 -nodes -keyout "${CERT_DIR}"/ssl-wildcard.key -out "${CERT_DIR}"/ssl-wildcard.pem -subj "/CN=wildcard"

# Change permissions
chown -R 101:101 /certs
chmod 0400 "${CERT_DIR}"/*
