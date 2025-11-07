/*
  * File: systemd.nix
  * Author: Leopold Meinel (leo@meinel.dev)
  * -----
  * Copyright (c) 2023 Leopold Meinel & contributors
  * SPDX ID: MIT
  * URL: https://opensource.org/licenses/MIT
  * -----
*/

{
  installEnv,
  ...
}:

{
  # systemd options (/etc/systemd/)
  systemd = {
    coredump.enable = false;
    network = {
      enable = true;
      wait-online.enable = true;
      networks."10-en" = {
        matchConfig.Name = "${installEnv.NETWORK_INTERFACE}";
        networkConfig.DHCP = "ipv4";
        address = [
          "${installEnv.IPV6_ADDRESS}"
        ];
        routes = [
          { Gateway = "fe80::1"; }
        ];
      };
    };
  };
}
