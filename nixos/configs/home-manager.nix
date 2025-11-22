/*
  File: home-manager.nix
  Author: Leopold Johannes Meinel (leo@meinel.dev)
  -----
  Copyright (c) 2025 Leopold Johannes Meinel & contributors
  SPDX ID: Apache-2.0
  URL: https://www.apache.org/licenses/LICENSE-2.0
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
