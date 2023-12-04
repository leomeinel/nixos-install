/*
  * File: common-home.nix
  * Author: Leopold Meinel (leo@meinel.dev)
  * -----
  * Copyright (c) 2023 Leopold Meinel & contributors
  * SPDX ID: GPL-3.0-or-later
  * URL: https://www.gnu.org/licenses/gpl-3.0-standalone.html
  * -----
*/

{ inputs, outputs, lib, config, pkgs, ... }:

{
  # Imports
  imports = [ ];

  # nixpkgs options
  nixpkgs = {
    overlays = [ ];
    config = { };
  };

  # Home options
  home = {
    # State version
    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "REPLACE_NIX_VERSION";
    # Packages
    packages = with pkgs; [ ];
    # Files in $HOME
    file = {
      "${config.xdg.configHome}" = {
        source = ./files/.config;
        recursive = true;
      };
      "post.sh" = {
        source = ./files/scripts/post.sh;
        executable = true;
      };
    };
    # Activation script
    activation = {
      nixos-install = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        # Create src
        mkdir -p ~/src
        chmod 700 ~/src

        # Create XDG dirs
        mkdir -p "$XDG_DATA_HOME"/android
        mkdir -p "$XDG_DATA_HOME"/cargo
        mkdir -p "$XDG_DATA_HOME"/go
        mkdir -p "$XDG_DATA_HOME"/platformio
        mkdir -p "$XDG_DATA_HOME"/r/library
        mkdir -p "$XDG_DATA_HOME"/rustup
        mkdir -p "$XDG_STATE_HOME"/bash
        mkdir -p "$XDG_STATE_HOME"/r
        mkdir -p "$XDG_DATA_HOME"/gnupg
        chmod 700 "$XDG_DATA_HOME"/gnupg
      '';
    };
  };

  # Program options
  programs = {
    home-manager.enable = true;
    # neovim options
    neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      vimdiffAlias = true;
    };
    # git options and config
    git = {
      enable = true;
      userEmail = "leo@meinel.dev";
      userName = "Leopold Johannes Meinel";
      signing.signByDefault = true;
      # git delta
      delta = {
        enable = true;
        options = {
          decorations = {
            commit-decoration-style = "blue ol";
            commit-style = "raw";
            file-style = "omit";
            hunk-header-decoration-style = "blue box";
            hunk-header-file-style = "red";
            hunk-header-line-number-style = "#067a00";
            hunk-header-style = "file line-number syntax";
          };
          interactive.keep-plus-minus-markers = false;
          navigate = true;
          light = false;
          features = "decorations";
        };
      };
      # custom config
      extraConfig = {
        core = {
          editor = "nvim";
          autocrlf = "input";
        };
        init.defaultBranch = "main";
        pull.rebase = true;
        merge.conflictstyle = "diff3";
        diff.colorMoved = "default";
        add.interactive.useBuiltin = false;
        credential.helper = "${pkgs.git.override { withLibsecret = true; }}/bin/git-credential-libsecret";
      };
    };
  };
}
