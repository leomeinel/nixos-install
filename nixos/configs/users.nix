/*
  * File: users.nix
  * Author: Leopold Meinel (leo@meinel.dev)
  * -----
  * Copyright (c) 2023 Leopold Meinel & contributors
  * SPDX ID: GPL-3.0-or-later
  * URL: https://www.gnu.org/licenses/gpl-3.0-standalone.html
  * -----
*/

{ inputs, lib, config, pkgs, ... }:

{
  # User options
  users = {
    # Groups
    # FIXME: Use system groups
    groups = {
      audit = { };
      usbguard = { };
    };
    # Users
    users = {
      root = {
        initialPassword = "REPLACE_INITIAL_PASSWORD";
      };
      systux = {
        isNormalUser = true;
        extraGroups = [ "adm" "audit" "systemd-journal" "usbguard" "wheel" "video" ];
        openssh.authorizedKeys.keys = [ "REPLACE_SYSUSER_PUBKEY" ];
        initialPassword = "REPLACE_INITIAL_PASSWORD";
      };
      virt = {
        isNormalUser = true;
        extraGroups = [ "podman" "video" ];
        openssh.authorizedKeys.keys = [ "REPLACE_VIRTUSER_PUBKEY" ];
        initialPassword = "REPLACE_INITIAL_PASSWORD";
      };
      leo = {
        isNormalUser = true;
        extraGroups = [ "video" ];
        openssh.authorizedKeys.keys = [ "REPLACE_HOMEUSER_PUBKEY" ];
        initialPassword = "REPLACE_INITIAL_PASSWORD";
      };
    };
  };
}
