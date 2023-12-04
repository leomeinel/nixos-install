/*
  * File: home-manager.nix
  * Author: Leopold Meinel (leo@meinel.dev)
  * -----
  * Copyright (c) 2023 Leopold Meinel & contributors
  * SPDX ID: GPL-3.0-or-later
  * URL: https://www.gnu.org/licenses/gpl-3.0-standalone.html
  * -----
*/

{ inputs, outputs, ... }: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager = {
    extraSpecialArgs = { inherit inputs outputs; };
    users = {
      root = import ../home-manager/ROOTUSER.nix;
      REPLACE_SYSUSER = import ../home-manager/SYSUSER.nix;
      REPLACE_VIRTUSER = import ../home-manager/VIRTUSER.nix;
      REPLACE_HOMEUSER = import ../home-manager/HOMEUSER.nix;
    };
  };
}
