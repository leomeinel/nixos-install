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
  imports = [ ];

  nixpkgs = {
    overlays = [ ];
    config = { };
  };

  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
  };
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    vimdiffAlias = true;
  };

  home = {
    packages = with pkgs; [ ];
    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "REPLACE_NIX_VERSION";
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

        # Initialize nvim
        nvim --headless -c 'sleep 5' -c 'q!' >/dev/null 2>&1
      '';
    };
    file = {
      "${config.xdg.configHome}" = {
        source = "./.config";
        recursive = true;
      };
      "post.sh" = {
        source = "./scripts/post.sh";
        executable = true;
      };
    };
  };
}
