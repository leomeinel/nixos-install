/*
  File: users.nix
  Author: Leopold Meinel (leo@meinel.dev)
  -----
  Copyright (c) 2025 Leopold Meinel & contributors
  SPDX ID: MIT
  URL: https://opensource.org/licenses/MIT
  -----
*/

{
  installEnv,
  ...
}:

{
  # User options
  users = {
    # Groups
    # FIXME: Use system groups
    groups = {
      audit = { };
      log = { };
      proc = { };
      rfkill = { };
      ssh-allow = { };
      sys = { };
      usbguard = { };
    };
    # Users
    users = {
      root = {
        initialPassword = "${installEnv.INITIAL_PASSWORD}";
      };
      ${installEnv.SYSUSER} = {
        isNormalUser = true;
        extraGroups = [
          "adm"
          "audit"
          "log"
          "proc"
          "rfkill"
          "ssh-allow"
          "sys"
          "systemd-journal"
          "usbguard"
          "video"
          "wheel"
        ];
        openssh.authorizedKeys.keys = [ "${installEnv.SYSUSER_PUBKEY}" ];
        initialPassword = "${installEnv.INITIAL_PASSWORD}";
      };
    };
  };
}
