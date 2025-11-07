/*
  * File: virtualisation.nix
  * Author: Leopold Meinel (leo@meinel.dev)
  * -----
  * Copyright (c) 2023 Leopold Meinel & contributors
  * SPDX ID: MIT
  * URL: https://opensource.org/licenses/MIT
  * -----
*/

{
  ...
}:

{
  # Virtualisation options
  virtualisation = {
    podman = {
      enable = true;
      dockerSocket.enable = false;
      defaultNetwork.settings.dns_enabled = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
        flags = [
          "-a"
        ];
      };
    };
    oci-containers = { };
  };
}
