/*
  File: home-manager.nix
  Author: Leopold Meinel (leo@meinel.dev)
  -----
  Copyright (c) 2025 Leopold Meinel & contributors
  SPDX ID: MIT
  URL: https://opensource.org/licenses/MIT
  -----
*/

{
  inputs,
  installEnv,
  outputs,
  ...
}:

{
  # Imports
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];
  # home-manager options
  home-manager = {
    extraSpecialArgs = { inherit inputs outputs installEnv; };
    # Import user configs
    users = {
      root = import ../../home-manager/configs/ROOTUSER.nix;
      ${installEnv.SYSUSER} = import ../../home-manager/configs/SYSUSER.nix;
    };
  };
}
