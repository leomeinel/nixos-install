/*
  * File: configuration.nix
  * Author: Leopold Meinel (leo@meinel.dev)
  * -----
  * Copyright (c) 2023 Leopold Meinel & contributors
  * SPDX ID: GPL-3.0-or-later
  * URL: https://www.gnu.org/licenses/gpl-3.0-standalone.html
  * -----
*/

{ inputs, lib, config, pkgs, ... }:

{
  # Imports
  imports = [
    ./configs/hardware-configuration.nix
    ./configs/boot.nix
    ./configs/environment.nix
    ./configs/home-manager.nix
    ./configs/networking.nix
    ./configs/programs.nix
    ./configs/security.nix
    ./configs/services.nix
    ./configs/users.nix
  ];

  # System options
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "REPLACE_NIX_VERSION";

  # Nix options
  nix = {
    registry = (lib.mapAttrs (_: flake: { inherit flake; })) ((lib.filterAttrs (_: lib.isType "flake")) inputs);
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
    };
  };

  # Filesystem options
  fileSystems = {
    # CODEGEN: fileSystems #
    # tmpfs
    "/dev/shm" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [ "rw" "noexec" "nodev" "nosuid" ];
    };
    "/tmp" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [ "rw" "noexec" "nodev" "nosuid" "uid=0" "gid=0" "mode=1700" ];
    };
  };

  # Equivalent to /etc/systemd/zram-generator.conf
  zramSwap = {
    enable = true;
    memoryPercent = 100;
    algorithm = "zstd";
  };

  # systemd options
  systemd = {
    coredump.enable = false;
    network = {
      enable = true;
      wait-online.enable = true;
      networks."10-wan" = {
        matchConfig.Name = "REPLACE_NETWORK_INTERFACE";
        networkConfig.DHCP = "ipv4";
        address = [
          "REPLACE_IPV6_ADDRESS"
        ];
        routes = [
          { routeConfig.Gateway = "fe80::1"; }
        ];
      };
    };
  };

  # Region options
  console.keyMap = "REPLACE_KEYMAP";
  time.timeZone = "REPLACE_TIMEZONE";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [ "de_DE.UTF-8/UTF-8" "en_US.UTF-8/UTF-8" "en_DK.UTF-8/UTF-8" "fr_FR.UTF-8/UTF-8" "nl_NL.UTF-8/UTF-8" ];
    extraLocaleSettings = {
      LANGUAGE = "en_US.UTF-8:en_US:en:C";
      LC_ADDRESS = "en_US.UTF-8";
      LC_COLLATE = "en_US.UTF-8";
      LC_CTYPE = "en_US.UTF-8";
      LC_MESSAGES = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_TIME = "en_DK.UTF-8";
      LC_MEASUREMENT = "en_DK.UTF-8";
      LC_PAPER = "nl_NL.UTF-8";
      LC_TELEPHONE = "nl_NL.UTF-8";
      LC_IDENTIFICATION = "nl_NL.UTF-8";
    };
  };

  # Font options
  fonts.fontconfig.enable = false;

  # Virtualisation options
  virtualisation.podman = {
    enable = true;
    dockerSocket.enable = true;
    defaultNetwork.settings.dns_enabled = true;
  };
}
