/*
  File: file.nix
  Author: Leopold Johannes Meinel (leo@meinel.dev)
  -----
  Copyright (c) 2025 Leopold Johannes Meinel & contributors
  SPDX ID: Apache-2.0
  URL: https://www.apache.org/licenses/LICENSE-2.0
*/

{
  config,
  ...
}:

{
  # File options
  home.file = {
    "${config.home.homeDirectory}/.bash_logout" = {
      source = ../../files/.bash_logout;
    };
    "${config.home.homeDirectory}/.bash_profile" = {
      source = ../../files/.bash_profile;
    };
  };
}
