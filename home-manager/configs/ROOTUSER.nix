/*
  File: ROOTUSER.nix
  Author: Leopold Johannes Meinel (leo@meinel.dev)
  -----
  Copyright (c) 2025 Leopold Johannes Meinel & contributors
  SPDX ID: Apache-2.0
  URL: https://www.apache.org/licenses/LICENSE-2.0
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
