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
    logind.killUserProcesses = true;
    # FIXME: Enable this immediately after 25.11 upgrade and remove above line
    # logind.settings.Login = {
    #   KillUserProcesses = true;
    # };
    # usbguard options (/etc/usbguard/usbguard.conf)
    usbguard = {
      enable = true;
      IPCAllowedGroups = [ "usbguard" ];
    };
    # postfix options (/etc/postfix/main.cf)
    postfix = {
      enable = true;
      extraConfig = ''
        myhostname = localhost
        mydomain = localdomain
        mydestination = $myhostname, localhost.$mydomain, localhost
        inet_interfaces = $myhostname, localhost
        mynetworks_style = host
        default_transport = error: outside mail is not deliverable
        disable_vrfy_command = yes
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
        AllowGroups = [ "ssh-allow" ];
      };
    };
  };
}
