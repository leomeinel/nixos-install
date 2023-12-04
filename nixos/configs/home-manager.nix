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
  # Imports
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];
  # home-manager options
  home-manager = {
    extraSpecialArgs = { inherit inputs outputs; };
    # Import user configs
    users = {
      root = import ../../home-manager/configs/ROOTUSER.nix;
      REPLACE_SYSUSER = import ../../home-manager/configs/SYSUSER.nix;
      REPLACE_VIRTUSER = import ../../home-manager/configs/VIRTUSER.nix;
      REPLACE_HOMEUSER = import ../../home-manager/configs/HOMEUSER.nix;
    };
  };
}
