/*
  File: common-home.nix
  Author: Leopold Meinel (leo@meinel.dev)
  -----
  Copyright (c) 2025 Leopold Meinel & contributors
  SPDX ID: MIT
  URL: https://opensource.org/licenses/MIT
  -----
*/

{
  config,
  installEnv,
  lib,
  pkgs,
  ...
}:

{
  # Imports
  imports = [
    ./configs/home/file.nix
    ./configs/home/programs.nix
    ./configs/home/xdg.nix
  ];

  # Nixpkgs options
  nixpkgs = {
    overlays = [ ];
    config = { };
  };

  # Home options
  home = {
    # State version
    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "${installEnv.NIX_VERSION}";
    # Packages
    packages = with pkgs; [
      xdg-ninja
    ];
    # Activation script
    activation = {
      common-home = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        # Create dirs
        run ${pkgs.coreutils-full}/bin/mkdir -p ${config.home.homeDirectory}/.ssh
        run ${pkgs.coreutils-full}/bin/chmod 700 ${config.home.homeDirectory}/.ssh
        run ${pkgs.coreutils-full}/bin/mkdir -p ${config.home.homeDirectory}/src
        run ${pkgs.coreutils-full}/bin/chmod 700 ${config.home.homeDirectory}/src

        # Create XDG dirs
        run ${pkgs.coreutils-full}/bin/mkdir -p ${config.xdg.cacheHome}
        run ${pkgs.coreutils-full}/bin/mkdir -p ${config.xdg.configHome}
        run ${pkgs.coreutils-full}/bin/mkdir -p ${config.xdg.dataHome}
        run ${pkgs.coreutils-full}/bin/mkdir -p ${config.xdg.stateHome}
        run ${pkgs.coreutils-full}/bin/mkdir -p ${config.xdg.configHome}/java
        run ${pkgs.coreutils-full}/bin/mkdir -p ${config.xdg.dataHome}/android
        run ${pkgs.coreutils-full}/bin/mkdir -p ${config.xdg.dataHome}/cargo
        run ${pkgs.coreutils-full}/bin/mkdir -p ${config.xdg.dataHome}/gnupg
        run ${pkgs.coreutils-full}/bin/chmod 700 ${config.xdg.dataHome}/gnupg
        run ${pkgs.coreutils-full}/bin/mkdir -p ${config.xdg.dataHome}/go
        run ${pkgs.coreutils-full}/bin/mkdir -p ${config.xdg.dataHome}/gradle
        run ${pkgs.coreutils-full}/bin/mkdir -p ${config.xdg.configHome}/gtk-2.0
        run ${pkgs.coreutils-full}/bin/mkdir -p ${config.xdg.stateHome}/bash
        run ${pkgs.coreutils-full}/bin/mkdir -p ${config.xdg.configHome}/parallel
        run ${pkgs.coreutils-full}/bin/mkdir -p ${config.xdg.dataHome}/platformio
        run ${pkgs.coreutils-full}/bin/mkdir -p ${config.xdg.configHome}/r
        run ${pkgs.coreutils-full}/bin/mkdir -p ${config.xdg.dataHome}/r/library
        run ${pkgs.coreutils-full}/bin/mkdir -p ${config.xdg.stateHome}/r
        run ${pkgs.coreutils-full}/bin/mkdir -p ${config.xdg.stateHome}/radian
        run ${pkgs.coreutils-full}/bin/mkdir -p ${config.xdg.dataHome}/rustup
        run ${pkgs.coreutils-full}/bin/mkdir -p ${config.xdg.configHome}/screen
        run ${pkgs.coreutils-full}/bin/mkdir -p ${config.xdg.cacheHome}/texlive
      '';
    };
  };

  # Nix options
  nix = {
    gc = {
      automatic = true;
      frequency = "weekly";
      options = "--delete-older-than 30d";
    };
  };
}
