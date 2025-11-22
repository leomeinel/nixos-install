/*
  File: programs.nix
  Author: Leopold Johannes Meinel (leo@meinel.dev)
  -----
  Copyright (c) 2025 Leopold Johannes Meinel & contributors
  SPDX ID: Apache-2.0
  URL: https://www.apache.org/licenses/LICENSE-2.0
*/

{
  ...
}:

{
  # Program options
  programs = {
    # Select programs
    gnupg.agent.enable = true;
    starship.enable = true;
    htop.enable = true;
    git.enable = true;
    nano.enable = false;
    # bash options
    bash = {
      completion.enable = true;
      # Equivalent to .bashrc for interactive sessions
      interactiveShellInit = ''
        # Key bindings
        bind '"\e[A": history-search-backward'
        bind '"\e[B": history-search-forward'

        # History
        HISTCONTROL=ignoredups:ignorespace
        HISTSIZE=10000
        HISTFILESIZE=100000
        shopt -s histappend

        # Line wrap on window resize
        shopt -s checkwinsize

        # Tab completion for doas
        complete -F _command doas

        # Avoid non 0 exit status
        true
      '';
      # Aliases
      shellAliases = {
        # Aliases for sudo/doas to also use aliases
        doas = "doas ";
        sudo = "sudo ";

        # Rust core-utils
        bat = "bat --decorations auto --color auto";
        eza = "eza -lag --color=automatic";
        ll = "eza -lag --color=automatic";
        fd = "fd -Hs -c auto";
        hyperfine = "hyperfine -w 3 -r 12 --style auto";
        rg = "rg -s --color auto";

        # xdg-ninja recommendations
        adb = "HOME=\"\${XDG_DATA_HOME}\"/android command adb";
        wget = "wget --hsts-file=\"\${XDG_DATA_HOME}\"/wget-hsts";
        java = "java -Djava.util.prefs.userRoot=\${XDG_CONFIG_HOME}/java";
      };
    };
  };
}
