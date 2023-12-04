/*
  * File: HOMEUSER.nix
  * Author: Leopold Meinel (leo@meinel.dev)
  * -----
  * Copyright (c) 2023 Leopold Meinel & contributors
  * SPDX ID: GPL-3.0-or-later
  * URL: https://www.gnu.org/licenses/gpl-3.0-standalone.html
  * -----
*/

{ inputs, outputs, lib, config, pkgs, ... }:

{
  imports = [ ./common-home.nix ];

  home = {
    username = "REPLACE_HOMEUSER";
    homeDirectory = "/home/REPLACE_HOMEUSER";
  };

  programs.git.signing.key = "2D39C0733D0EF05E";
}