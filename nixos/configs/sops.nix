/*
  File: sops.nix
  Author: Leopold Meinel (leo@meinel.dev)
  -----
  Copyright (c) 2025 Leopold Meinel & contributors
  SPDX ID: MIT
  URL: https://opensource.org/licenses/MIT
  -----
*/

{
  ...
}:

{
  sops = {
    age.keyFile = "/root/.local/share/age/keys/nixos-install.txt";
    age.generateKey = false;
    secrets = { };
    templates = { };
  };
}
