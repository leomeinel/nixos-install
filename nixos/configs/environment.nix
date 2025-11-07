/*
  File: environment.nix
  Author: Leopold Meinel (leo@meinel.dev)
  -----
  Copyright (c) 2025 Leopold Meinel & contributors
  SPDX ID: MIT
  URL: https://opensource.org/licenses/MIT
  -----
*/

{
  lib,
  pkgs,
  ...
}:

{
  # Environment options
  environment = {
    # Packages
    ## Disable default packages
    defaultPackages = lib.mkForce [ ];
    ## Define packages
    systemPackages = with pkgs; [
      bat
      bc
      dosfstools
      du-dust
      duf
      ethtool
      eza
      fastfetch
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
      mtools
      netcat-openbsd
      ntfs3g
      openssl
      oxipng
      p7zip
      perl
      procs
      quilt
      rename
      ripgrep
      rsync
      screen
      skopeo
      tokei
      tree
      unar
      unixtools.xxd
      unzip
      vulnix
      wget
      yq
    ];
    # /etc
    etc = {
      "issue".source = ../files/etc/issue;
      "issue.net".source = ../files/etc/issue.net;
      "motd".source = ../files/etc/motd;
    };
    # Session variables
    sessionVariables = rec {
      # FIXME: This should normally be set by home-manager
      XDG_CACHE_HOME = "\${HOME}/.cache";
      XDG_CONFIG_HOME = "\${HOME}/.config";
      XDG_DATA_HOME = "\${HOME}/.local/share";
      XDG_STATE_HOME = "\${HOME}/.local/state";
      # Set environment variables
      ANDROID_HOME = "${XDG_DATA_HOME}/android";
      ANDROID_USER_HOME = "${XDG_DATA_HOME}/android";
      CARGO_HOME = "${XDG_DATA_HOME}/cargo";
      DIFFPROG = "${pkgs.neovim}/bin/nvim -d";
      GNUPGHOME = "${XDG_DATA_HOME}/gnupg";
      GOPATH = "${XDG_DATA_HOME}/go";
      GRADLE_USER_HOME = "${XDG_DATA_HOME}/gradle";
      HISTFILE = "${XDG_STATE_HOME}/bash/history";
      MANPAGER = "${pkgs.bashInteractive}/bin/sh -c '${pkgs.util-linux}/bin/col -bx | ${pkgs.bat}/bin/bat -l man -p'";
      MANROFFOPT = "-c";
      MYSQL_HOME = "/var/lib/mysql";
      NODE_REPL_HISTORY = "${XDG_DATA_HOME}/node_repl_history";
      NPM_CONFIG_USERCONFIG = "${XDG_CONFIG_HOME}/npm/npmrc";
      PAGER = "${pkgs.less}/bin/less";
      PARALLEL_HOME = "${XDG_CONFIG_HOME}/parallel";
      PLATFORMIO_CORE_DIR = "${XDG_DATA_HOME}/platformio";
      R_ENVIRON_USER = "${XDG_CONFIG_HOME}/r/Renviron";
      RUSTUP_HOME = "${XDG_DATA_HOME}/rustup";
      SCREENRC = "${XDG_CONFIG_HOME}/screen/screenrc";
      TEXMFVAR = "${XDG_CACHE_HOME}/texlive/texmf-var";
      VISUAL = "${pkgs.neovim}/bin/nvim";
    };
  };
}
