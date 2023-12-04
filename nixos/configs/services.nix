/*
  * File: services.nix
  * Author: Leopold Meinel (leo@meinel.dev)
  * -----
  * Copyright (c) 2023 Leopold Meinel & contributors
  * SPDX ID: GPL-3.0-or-later
  * URL: https://www.gnu.org/licenses/gpl-3.0-standalone.html
  * -----
*/

{ inputs, lib, config, pkgs, ... }:

{
  # Services options
  services = {
    # Select programs
    fwupd.enable = true;
    qemuGuest.enable = true;
    logrotate.enable = true;
    sysstat.enable = true;
    # usbguard options
    usbguard = {
      enable = true;
      IPCAllowedGroups = [ "usbguard" ];
    };
    # postfix options
    postfix = {
      enable = true;
      extraConfig = ''
        disable_vrfy_command = yes
        inet_interfaces = loopback-only
        smtpd_banner = "$myhostname ESMTP"
      '';
    };
    # openssh options (/etc/ssh/sshd_config)
    openssh = {
      enable = true;
      ports = [ 9122 ];
      allowSFTP = true;
      settings = {
        PasswordAuthentication = false;
        AuthenticationMethods = "publickey";
        PermitRootLogin = "no";
        AllowTcpForwarding = "no";
        ClientAliveCountMax = 2;
        LogLevel = "VERBOSE";
        MaxAuthTries = 3;
        MaxSessions = 2;
        TCPKeepAlive = "no";
        AllowAgentForwarding = "no";
        Banner = "/etc/issue.net";
      };
    };
  };
}
