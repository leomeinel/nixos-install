/*
  * File: ROOTUSER.nix
  * Author: Leopold Meinel (leo@meinel.dev)
  * -----
  * Copyright (c) 2023 Leopold Meinel & contributors
  * SPDX ID: MIT
  * URL: https://opensource.org/licenses/MIT
  * -----
*/

{
  lib,
  ...
}:

{
  # Imports
  imports = [ ../common-home.nix ];

  # Additional git options
  #programs.git.signing.key = "2D39C0733D0EF05E";

  # Home options
  home = {
    username = "root";
    homeDirectory = "/root";
    # Activation script
    activation = {
      sysuser = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        # Create backup directory
        mkdir -p ~/backup
      '';
    };
  };
}
