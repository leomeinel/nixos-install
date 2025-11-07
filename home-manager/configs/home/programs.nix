/*
  File: programs.nix
  Author: Leopold Meinel (leo@meinel.dev)
  -----
  Copyright (c) 2025 Leopold Meinel & contributors
  SPDX ID: MIT
  URL: https://opensource.org/licenses/MIT
  -----
*/

{
  pkgs,
  ...
}:

{
  # Programs options
  programs = {
    home-manager.enable = true;
    neovim =
      let
        toLuaFile = file: ''
          lua <<EOF
          ${builtins.readFile file}
          EOF
        '';
      in
      {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
        vimdiffAlias = true;
        extraLuaConfig = builtins.readFile ../../files/programs/neovim/init.lua;
        plugins = with pkgs.vimPlugins; [
          {
            plugin = gruvbox-nvim;
            config = toLuaFile ../../files/programs/neovim/plugin/gruvbox-nvim.lua;
          }
          {
            plugin = nvim-tree-lua;
            config = toLuaFile ../../files/programs/neovim/plugin/nvim-tree-lua.lua;
          }
          {
            plugin = nvim-web-devicons;
            config = toLuaFile ../../files/programs/neovim/plugin/nvim-web-devicons.lua;
          }
        ];
      };
    # git options and config (.config/git/config)
    git = {
      enable = true;
      userEmail = "leo@meinel.dev";
      userName = "Leopold Johannes Meinel";
      #signing.signByDefault = true;
      # git delta
      delta = {
        enable = true;
        options = {
          decorations = {
            commit-decoration-style = "blue ol";
            commit-style = "raw";
            file-style = "omit";
            hunk-header-decoration-style = "blue box";
            hunk-header-file-style = "red";
            hunk-header-line-number-style = "#067a00";
            hunk-header-style = "file line-number syntax";
          };
          interactive.keep-plus-minus-markers = false;
          navigate = true;
          light = false;
          features = "decorations";
        };
      };
      # custom config
      extraConfig = {
        core = {
          editor = "nvim";
          autocrlf = "input";
        };
        init.defaultBranch = "main";
        pull.rebase = true;
        merge.conflictstyle = "diff3";
        diff.colorMoved = "default";
        add.interactive.useBuiltin = false;
        credential.helper = "${pkgs.git.override { withLibsecret = true; }}/bin/git-credential-libsecret";
      };
    };
  };
}
