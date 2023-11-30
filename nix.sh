#!/usr/bin/env bash
###
# File: nix.sh
# Author: Leopold Meinel (leo@meinel.dev)
# -----
# Copyright (c) 2023 Leopold Meinel & contributors
# SPDX ID: GPL-3.0-or-later
# URL: https://www.gnu.org/licenses/gpl-3.0-standalone.html
# -----
###

# TODO: Add correct commands to install on Hetzner Cloud from scratch
sudo loadkeys de-latin1
sudo -i
nix-env -iA nixos.git
git clone https://github.com/leomeinel/nixos-install.git
chmod +x ./nixos-install/prepare.sh
./nixos-install/prepare.sh
nixos-generate-config --root /mnt
