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
      root = import ../home-manager/home.nix;
      systux = import ../home-manager/home.nix;
      virt = import ../home-manager/home.nix;
      leo = import ../home-manager/home.nix;
    };
  };
}
