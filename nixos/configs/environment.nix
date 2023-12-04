/*
  * File: environment.nix
  * Author: Leopold Meinel (leo@meinel.dev)
  * -----
  * Copyright (c) 2023 Leopold Meinel & contributors
  * SPDX ID: GPL-3.0-or-later
  * URL: https://www.gnu.org/licenses/gpl-3.0-standalone.html
  * -----
*/

{ inputs, lib, config, pkgs, ... }:

{
  # Environment options
  environment = {
    # Packages
    ## Disable default packages
    defaultPackages = lib.mkForce [ ];
    # /etc
    etc = {
      "issue".source = ../files/etc/issue;
      "issue.net".source = ../files/etc/issue.net;
      "motd".source = ../files/etc/motd;
      # FIXME: Figure out how to overwrite /etc/hosts without using environment.etc
      "hosts".text = lib.mkForce
        (
          ''
            127.0.0.1 localhost
            127.0.1.1 REPLACE_HOSTNAME.REPLACE_DOMAIN REPLACE_HOSTNAME
            ::1 ip6-localhost ip6-loopback
            ff02::1 ip6-allnodes
            ff02::2 ip6-allrouters
          ''
        );
    };
    # Session variables
    sessionVariables = rec {
      XDG_CACHE_HOME = "$HOME/.cache";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_STATE_HOME = "$HOME/.local/state";
      PAGER = "less";
      VISUAL = "nvim";
      MANPAGER = "sh -c 'col -bx | bat -l man -p'";
      MANROFFOPT = "-c";
      ANDROID_HOME = "${XDG_DATA_HOME}/android";
      CARGO_HOME = "${XDG_DATA_HOME}/cargo";
      GNUPGHOME = "${XDG_DATA_HOME}/gnupg";
      GOPATH = "${XDG_DATA_HOME}/go";
      GRADLE_USER_HOME = "${XDG_DATA_HOME}/gradle";
      GTK2_RC_FILES = "${XDG_CONFIG_HOME}/gtk-2.0/gtkrc";
      HISTFILE = "${XDG_STATE_HOME}/bash/history";
      PLATFORMIO_CORE_DIR = "${XDG_DATA_HOME}/platformio";
      R_ENVIRON_USER = "${XDG_CONFIG_HOME}/r/.Renviron";
      RUSTUP_HOME = "${XDG_DATA_HOME}/rustup";
    };
    ## Define packages
    systemPackages = with pkgs; [
      bat
      bc
      dosfstools
      du-dust
      duf
      ethtool
      eza
      fd
      glow
      gptfdisk
      hwinfo
      hyperfine
      inetutils
      jpegoptim
      jq
      libpwquality
      lrzip
      lshw
      lsof
      lzop
      macchina
      mtools
      netcat-openbsd
      ntfs3g
      oxipng
      p7zip
      perl
      podman-compose
      procs
      quilt
      rename
      ripgrep
      rsync
      screen
      tokei
      tree
      unar
      unixtools.xxd
      unzip
      wget
      xdg-ninja
      yq
    ];
  };
}
