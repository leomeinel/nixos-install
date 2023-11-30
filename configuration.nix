###
# File: configuration.nix
# Author: Leopold Meinel (leo@meinel.dev)
# -----
# Copyright (c) 2023 Leopold Meinel & contributors
# SPDX ID: GPL-3.0-or-later
# URL: https://www.gnu.org/licenses/gpl-3.0-standalone.html
# -----
###

# TODO!
{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.initrd.kernelModules = [ "virtio_gpu" ];
  boot.kernelParams = [ "console=tty" ];
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    # https://www.rfc-editor.org/rfc/rfc1178.html
    # Network devices: elements
    # Servers: colors
    # Clients: flowers
    hostName = "red";
    # https://www.rfc-editor.org/rfc/rfc8375.html
    domain = "cloud.arpa";
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 443 9122 9123 ];
      allowedUDPPorts = [ ];
    };
  };
  systemd.network = {
    enable = true;
    networks."10-wan" = {
      matchConfig.Name = "enp1s0";
      networkConfig.DHCP = "ipv4";
      address = [
        "2a01:4f8:1c1b:8520::1/64"
      ];
      routes = [
        { routeConfig.Gateway = "fe80::1"; }
      ];
    };
  };

  time.timeZone = "Etc/UTC";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [ "de_DE.UTF-8 UTF-8" "en_US.UTF-8 UTF-8" "en_DK.UTF-8 UTF-8" "fr_FR.UTF-8 UTF-8" "nl_NL.UTF-8 UTF-8" ];
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

  console.keyMap = "de-latin1";

  security.doas = {
    enable = true;
    extraRules = [{
      persist = true;
      setEnv = [ "LANG" "LC_ALL" ];
      groups = [ "wheel" ];
    }];
  };
  security.sudo.enable = false;

  users.users = {
    systux = {
      isNormaluser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGswEJVocQdIFn8ePBbiRXnKjvHZ51xkpZy5UFbljj93 virt@tulip" ];
    };
    dock = {
      isNormaluser = true;
      extraGroups = [ "docker" ];
      openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINpfWmMbqjzXGRiSQRfA0bXUi+3fHZn4uxBLtKJjUMKP virt@tulip" ];
    };
    leo = {
      isNormaluser = true;
      openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAeyG1LTUIvtKmiasP0f/ulrChmwINR9jrHBxrJV57gG virt@tulip" ];
    };
  };

  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    bash-completion
    bat
    bc
    dosfstools
    du-dust
    duf
    ethtool
    fd
    git
    git-extras
    glow
    gptfdisk
    htop
    hwinfo
    hyperfine
    inetutils
    jpegoptim
    jq
    lrzip
    lshw
    lsof
    lzop
    macchina
    man
    mtools
    neovim
    netcat-openbsd
    noto-fonts
    ntfs-3g
    oxipng
    p7zip
    procs
    quilt
    rename
    ripgrep
    rsync
    screen
    sshfs
    starship
    tokei
    tree
    unar
    unrar
    unzip
    wget
    xdg-ninja
    yq
  ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = "no";
      AuthenticationMethods = "publickey";
      PermitRootLogin = "no";
      AllowTcpForwarding = "no";
      ClientAliveCountMax = 2;
      LogLevel = "VERBOSE";
      MaxAuthTries = 3;
      MaxSessions = 2;
      Port = 9122;
      TCPKeepAlive = "no";
      AllowAgentForwarding = "no";
      Banner = "/etc/issue.net";
    };
  };
  services.fwupd.enable = true;

  system.stateVersion = "23.05";

  zramSwap = {
    enable = true;
    memoryPercent = 100;
    algorithm = "zstd";
  };
}
