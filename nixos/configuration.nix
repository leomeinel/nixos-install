/*
  File: configuration.nix
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
  lib,
  ...
}:

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
    ./configs/sops.nix
    ./configs/systemd.nix
    ./configs/users.nix
    ./configs/virtualisation.nix
  ];

  # System options
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "${installEnv.NIX_VERSION}";

  # Nix options
  nix = {
    registry = (lib.mapAttrs (_: flake: { inherit flake; })) (
      (lib.filterAttrs (_: lib.isType "flake")) inputs
    );
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      use-xdg-base-directories = true;
    };
  };

  # Filesystem options
  fileSystems = {
    # System
    # CODEGEN: fileSystems #
    # tmpfs
    "/dev/shm" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [
        "noexec"
        "nodev"
        "nosuid"
      ];
    };
    "/tmp" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [
        "nodev"
        "nosuid"
        "mode=1700"
      ];
    };
    "/proc" = {
      device = "proc";
      fsType = "proc";
      options = [
        "rw"
        "noexec"
        "nodev"
        "nosuid"
        "gid=proc"
        "hidepid=2"
      ];
    };
  };

  # zram options (/etc/systemd/zram-generator.conf)
  zramSwap = {
    enable = true;
    memoryPercent = 100;
    algorithm = "zstd";
  };

  # Region options
  ## Equivalent to (/etc/vconsole.conf)
  console.keyMap = "${installEnv.KEYMAP}";
  ## Equivalent to (/etc/localtime)
  time.timeZone = "${installEnv.TIMEZONE}";
  ## Equivalent to (/etc/locale.conf)
  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [
      "de_DE.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
      "en_DK.UTF-8/UTF-8"
      "fr_FR.UTF-8/UTF-8"
      "nl_NL.UTF-8/UTF-8"
    ];
    extraLocaleSettings = {
      LANGUAGE = "en_US.UTF-8";
      LC_ALL = "en_US.UTF-8";
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
}
