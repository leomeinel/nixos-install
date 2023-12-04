/*
  * File: VIRTUSER.nix
  * Author: Leopold Meinel (leo@meinel.dev)
  * -----
  * Copyright (c) 2023 Leopold Meinel & contributors
  * SPDX ID: GPL-3.0-or-later
  * URL: https://www.gnu.org/licenses/gpl-3.0-standalone.html
  * -----
*/

{ inputs, outputs, lib, config, pkgs, ... }:

{
  imports = [ "./common-home.nix" ];

  home = {
    username = "REPLACE_VIRTUSER";
    homeDirectory = "/home/REPLACE_VIRTUSER";
  };
}
