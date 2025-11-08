/*
  File: sops.nix
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
  sops = {
    age.keyFile = "/root/.local/share/age/keys/nixos-install.txt";
    age.generateKey = false;
    secrets = {
      "containers/volumes/certbot/cloudflare.ini" = {
        format = "ini";
        sopsFile = ../../secrets/files/containers/volumes/certbot/cloudflare.ini;
        mode = "0400";
      };
      "containers/volumes/reverse-proxy/certs/dhparams.pem" = {
        format = "binary";
        sopsFile = ../../secrets/files/containers/volumes/reverse-proxy/certs/dhparams.pem;
        mode = "0400";
        uid = 101;
        gid = 101;
      };
      "keys/gotify-${installEnv.HOSTNAME}-backup-container-volumes.pass" = {
        format = "binary";
        sopsFile = ../../secrets/files/keys/gotify-${installEnv.HOSTNAME}-backup-container-volumes.pass;
        mode = "0400";
      };
      "keys/gotify-${installEnv.HOSTNAME}-monitor-container-updates.pass" = {
        format = "binary";
        sopsFile = ../../secrets/files/keys/gotify-${installEnv.HOSTNAME}-monitor-container-updates.pass;
        mode = "0400";
      };
      "keys/gotify-${installEnv.HOSTNAME}-monitor-updates.pass" = {
        format = "binary";
        sopsFile = ../../secrets/files/keys/gotify-${installEnv.HOSTNAME}-monitor-updates.pass;
        mode = "0400";
      };
      "keys/gotify-${installEnv.HOSTNAME}-ssh-login.pass" = {
        format = "binary";
        sopsFile = ../../secrets/files/keys/gotify-${installEnv.HOSTNAME}-ssh-login.pass;
        mode = "0400";
      };
      "keys/${installEnv.HOSTNAME}-containers.bak_${installEnv.STORAGE_USER}.pass" = {
        format = "binary";
        sopsFile = ../../secrets/files/keys/${installEnv.HOSTNAME}-containers.bak_${installEnv.STORAGE_USER}.pass;
        mode = "0400";
      };
      "keys/${installEnv.HOSTNAME}-containers.bak.pass" = {
        format = "binary";
        sopsFile = ../../secrets/files/keys/${installEnv.HOSTNAME}-containers.bak.pass;
        mode = "0400";
      };
    };
  };
}
