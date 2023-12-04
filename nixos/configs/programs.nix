/*
  * File: programs.nix
  * Author: Leopold Meinel (leo@meinel.dev)
  * -----
  * Copyright (c) 2023 Leopold Meinel & contributors
  * SPDX ID: GPL-3.0-or-later
  * URL: https://www.gnu.org/licenses/gpl-3.0-standalone.html
  * -----
*/

{ inputs, lib, config, pkgs, ... }:

{
  # Program options
  programs = {
    # Select programs
    gnupg.agent.enable = true;
    ssh.startAgent = true;
    starship.enable = true;
    htop.enable = true;
    nano.enable = false;
    # Bash options
    bash = {
      enableCompletion = true;
      # Equivalent to .bashrc for interactive sessions
      interactiveShellInit = ''
        # Key bindings
        bind '"\e[A": history-search-backward'
        bind '"\e[B": history-search-forward'

        # History
        HISTCONTROL=ignoredups:ignorespace
        HISTSIZE=1000
        HISTFILESIZE=10000
        shopt -s histappend

        # Line wrap on window resize
        shopt -s checkwinsize

        # Tab completion for doas
        complete -cf doas
      '';
      # Aliases
      shellAliases = {
        # doas
        doas = "doas ";
        sudo = "sudo ";
        # btrfs
        df = "btrfs fi df";
        # Rust core-utils aliases
        ls = "eza -la --color=automatic";
        cat = "bat --decorations auto --color auto";
        grep = "rg -s --color auto";
        find = "fd -Hs -c auto";
        du = "dust";
        ps = "procs";
        neofetch = "macchina";
        bench = "hyperfine -w 3 -r 12 --style auto";
      };
    };
  };
}
