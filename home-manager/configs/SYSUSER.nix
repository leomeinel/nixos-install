/*
  * File: SYSUSER.nix
  * Author: Leopold Meinel (leo@meinel.dev)
  * -----
  * Copyright (c) 2023 Leopold Meinel & contributors
  * SPDX ID: GPL-3.0-or-later
  * URL: https://www.gnu.org/licenses/gpl-3.0-standalone.html
  * -----
*/

{ inputs, outputs, lib, config, pkgs, ... }:

{
  # Imports
  imports = [ ../common-home.nix ];

  # Additional git options
  #programs.git.signing.key = "2D39C0733D0EF05E";

  # Home options
  home = {
    username = "REPLACE_SYSUSER";
    homeDirectory = "/home/REPLACE_SYSUSER";
    file."post.sh" = {
      source = ../files/scripts/post.sh;
      executable = true;
    };
    # Activation script
    activation = {
      sysuser = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        # Create backup directory
        mkdir -p ~/backup
      '';
    };
  };
}
