/*
  File: services.nix
  Author: Leopold Meinel (leo@meinel.dev)
  -----
  Copyright (c) 2025 Leopold Meinel & contributors
  SPDX ID: MIT
  URL: https://opensource.org/licenses/MIT
  -----
*/

{
  ...
}:

{
  # Services options
  services = {
    # Select programs
    fwupd.enable = true;
    logrotate.enable = true;
    sysstat.enable = true;
    # usbguard options (/etc/usbguard/usbguard.conf)
    usbguard = {
      enable = true;
      IPCAllowedGroups = [ "usbguard" ];
    };
    # postfix options (/etc/postfix/main.cf)
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
