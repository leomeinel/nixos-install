/*
  * File: flake.nix
  * Author: Leopold Meinel (leo@meinel.dev)
  * -----
  * Copyright (c) 2023 Leopold Meinel & contributors
  * SPDX ID: MIT
  * URL: https://opensource.org/licenses/MIT
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
    # sops-nix
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  # Output options
  outputs =
    {
      home-manager,
      nixpkgs,
      self,
      sops-nix,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      installEnv = {
        SYSUSER_PUBKEY = "REPLACE_SYSUSER_PUBKEY";
        SYSUSER = "REPLACE_SYSUSER";
        INITIAL_PASSWORD = "REPLACE_INITIAL_PASSWORD";
        CERTBOT_TLD = "REPLACE_CERTBOT_TLD";
        NOTIFY_DOMAIN = "REPLACE_NOTIFY_DOMAIN";
        STORAGE_DOMAIN = "REPLACE_STORAGE_DOMAIN";
        STORAGE_PORT = "REPLACE_STORAGE_PORT";
        STORAGE_USER = "REPLACE_STORAGE_USER";
        HOSTNAME = "REPLACE_HOSTNAME";
        DOMAIN = "REPLACE_DOMAIN";
        NETWORK_INTERFACE = "REPLACE_NETWORK_INTERFACE";
        IPV6_ADDRESS = "REPLACE_IPV6_ADDRESS";
        KEYMAP = "REPLACE_KEYMAP";
        TIMEZONE = "REPLACE_TIMEZONE";
        NIX_VERSION = "REPLACE_NIX_VERSION";
      };
    in
    {
      # Configurations
      nixosConfigurations = {
        # Hosts
        ${installEnv.HOSTNAME} = nixpkgs.lib.nixosSystem {
          # Args to parse
          specialArgs = { inherit inputs outputs installEnv; };
          # Modules to use
          modules = [
            (nixpkgs + "/nixos/modules/profiles/hardened.nix")
            ./nixos/configuration.nix
            sops-nix.nixosModules.sops
          ];
        };
      };
    };
}
