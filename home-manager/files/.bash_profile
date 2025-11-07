#!/usr/bin/env bash
###
# File: .bash_profile
# Author: Leopold Meinel (leo@meinel.dev)
# -----
# Copyright (c) 2025 Leopold Meinel & contributors
# SPDX ID: MIT
# URL: https://opensource.org/licenses/MIT
# -----
###

# Commands that should be applied only for interactive shells
[[ "${-}" != *i* ]] &&
    return

# Set environment variables that need seperate declaration and assigning
GPG_TTY="$(tty)"
export GPG_TTY

# Start ssh-agent if it is not already started
[[ -z "${SSH_AUTH_SOCK}" ]] &&
    eval "$(ssh-agent -s)" >/dev/null 2>&1
