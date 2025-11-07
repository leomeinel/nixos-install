/*
  * File: SYSUSER.nix
  * Author: Leopold Meinel (leo@meinel.dev)
  * -----
  * Copyright (c) 2023 Leopold Meinel & contributors
  * SPDX ID: MIT
  * URL: https://opensource.org/licenses/MIT
  * -----
*/

{
  installEnv,
  ...
}:

{
  # Imports
  imports = [ ../common-home.nix ];

  # Additional git options
  #programs.git.signing.key = "2D39C0733D0EF05E";

  # Home options
  home = {
    username = "${installEnv.SYSUSER}";
    homeDirectory = "/home/${installEnv.SYSUSER}";
  };
}
