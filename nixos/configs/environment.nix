/*
  File: environment.nix
  Author: Leopold Johannes Meinel (leo@meinel.dev)
  -----
  Copyright (c) 2025 Leopold Johannes Meinel & contributors
  SPDX ID: Apache-2.0
  URL: https://www.apache.org/licenses/LICENSE-2.0
*/

{
  lib,
  pkgs,
  ...
}:

{
  # Environment options
  environment = {
    # /etc/profile.d
    extraInit = ''
      # Set TMOUT of 1d
      export TMOUT=86400

      # Set umask
      umask 027

      # Disable coredumps
      ulimit -c 0
    '';
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
      nvd
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
      # Containers
      ## volumes
      "containers/src/volumes/certs-reverse-proxy/certs.sh" = {
        source = ../files/containers/volumes/certs-reverse-proxy/certs.sh;
        mode = "0500";
      };
      "containers/src/volumes/nginx/includes/common.conf" = {
        source = ../files/containers/volumes/nginx/includes/common.conf;
        mode = "0400";
        uid = 101;
        gid = 101;
      };
      "containers/src/volumes/nginx/includes/fastcgi-headers.conf" = {
        source = ../files/containers/volumes/nginx/includes/fastcgi-headers.conf;
        mode = "0400";
        uid = 101;
        gid = 101;
      };
      "containers/src/volumes/nginx/includes/fastcgi.conf" = {
        source = ../files/containers/volumes/nginx/includes/fastcgi.conf;
        mode = "0400";
        uid = 101;
        gid = 101;
      };
      "containers/src/volumes/nginx/includes/headers-all.conf" = {
        source = ../files/containers/volumes/nginx/includes/headers-all.conf;
        mode = "0400";
        uid = 101;
        gid = 101;
      };
      "containers/src/volumes/nginx/includes/headers-apache-answer.conf" = {
        source = ../files/containers/volumes/nginx/includes/headers-apache-answer.conf;
        mode = "0400";
        uid = 101;
        gid = 101;
      };
      "containers/src/volumes/nginx/includes/headers-home-assistant.conf" = {
        source = ../files/containers/volumes/nginx/includes/headers-home-assistant.conf;
        mode = "0400";
        uid = 101;
        gid = 101;
      };
      "containers/src/volumes/nginx/includes/headers-trilium.conf" = {
        source = ../files/containers/volumes/nginx/includes/headers-trilium.conf;
        mode = "0400";
        uid = 101;
        gid = 101;
      };
      "containers/src/volumes/nginx/includes/proxy-headers.conf" = {
        source = ../files/containers/volumes/nginx/includes/proxy-headers.conf;
        mode = "0400";
        uid = 101;
        gid = 101;
      };
      "containers/src/volumes/nginx/includes/redirect.conf" = {
        source = ../files/containers/volumes/nginx/includes/redirect.conf;
        mode = "0400";
        uid = 101;
        gid = 101;
      };
      "containers/src/volumes/nginx/includes/restrict-to-local.conf" = {
        source = ../files/containers/volumes/nginx/includes/restrict-to-local.conf;
        mode = "0400";
        uid = 101;
        gid = 101;
      };
      "containers/src/volumes/nginx/includes/ssl-cloudflare.conf" = {
        source = ../files/containers/volumes/nginx/includes/ssl-cloudflare.conf;
        mode = "0400";
        uid = 101;
        gid = 101;
      };
      "containers/src/volumes/nginx/includes/ssl.conf" = {
        source = ../files/containers/volumes/nginx/includes/ssl.conf;
        mode = "0400";
        uid = 101;
        gid = 101;
      };
      "containers/src/volumes/nginx/nginx.conf" = {
        source = ../files/containers/volumes/nginx/nginx.conf;
        mode = "0400";
        uid = 101;
        gid = 101;
      };
      "containers/src/volumes/reverse-proxy/conf.d/sites-enabled/reverse-proxy.conf" = {
        source = ../files/containers/volumes/reverse-proxy/conf.d/sites-enabled/reverse-proxy.conf;
        mode = "0400";
        uid = 101;
        gid = 101;
      };
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
