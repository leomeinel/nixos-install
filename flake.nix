/*
  * File: flake.nix
  * Author: Leopold Meinel (leo@meinel.dev)
  * -----
  * Copyright (c) 2023 Leopold Meinel & contributors
  * SPDX ID: GPL-3.0-or-later
  * URL: https://www.gnu.org/licenses/gpl-3.0-standalone.html
  * -----
*/

{
  # Description of the flake
  description = "nixos-install for cloud servers";

  # Input options
  inputs = {
    # nixpkgs
    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    nixpkgs.url = "github:nixos/nixpkgs/nixos-REPLACE_NIX_VERSION";

    # home-manager
    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    home-manager.url = "github:nix-community/home-manager/release-REPLACE_NIX_VERSION";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  # Output options
  outputs =
    { self
    , nixpkgs
    , home-manager
    , ...
    } @ inputs:
    let
      inherit (self) outputs;
    in
    {
      # Configurations
      nixosConfigurations = {
        # Hosts
        REPLACE_HOSTNAME = nixpkgs.lib.nixosSystem {
          # Args to parse
          specialArgs = { inherit inputs outputs; };
          # Modules to use
          modules = [
            (nixpkgs + "/nixos/modules/profiles/hardened.nix")
            ./nixos/configuration.nix
          ];
        };
      };
    };
}
