args: {
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    optionalString
    ;
  cfg = config.khome.shell.zsh;
  keyBindings = builtins.readFile ./key-bindings.zsh;
  fzf-tab-conf = ''
    zstyle ":completion:*:git-checkout:*" sort false
    zstyle ':completion:*:descriptions' format '[%d]'
    zstyle ':completion:*' list-colors ${"\${(s.:.)LS_COLORS}"}
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'lsd -1 --color=always $realpath'
  '';
in {
  imports = [./fix-nix-shell-completions.nix];

  options.khome.shell.zsh = {
    enable = mkEnableOption "enable zsh";
    enableYazi = mkEnableOption "enable zsh" // {default = true;}; # TODO: change to `khome.shell.yazi.enable` default
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nix-zsh-completions

      # rust alternatives
      fd # find alternative
      bat # cat alternative
      eza # ls alternative
      lsd # ls alternative
      ripgrep # grep alternative
      bottom # top alternative (old)
      btop # top alternative
      broot # file explorer
      xplr # file explorer
      jc # json output for many unix cli commands
    ];

    home.sessionVariables = {
      TERM = "xterm-256color";
      MANPAGER = "sh -c 'col -bx | bat -l man -p'";
      MANROFFOPT = "-c";
    };

    programs.zsh = {
      enable = true;
      initExtra =
        keyBindings
        + fzf-tab-conf
        + ''
           # ctrl-w, alt-b (etc.) stop at chars like `/:` instead of just space
           autoload -U select-word-style
           select-word-style bash

           bindkey '^r' fzf-history-widget  # [Ctrl-r] - Search backward incrementally for a specified string. The string may begin with ^ to anchor the search to the beginning of the line.
           bindkey ' ' magic-space          # [Space] - don't do history expansion


           # Edit the current command line in $EDITOR
           autoload -U edit-command-line
           zle -N edit-command-line
           bindkey '\C-e' edit-command-line

           # file rename magick
           bindkey "^[m" copy-prev-shell-word

           # export SSH_AUTH_SOCK=`readlink ~/.ssh/auth_sock`

          export SSH_AUTH_SOCK="/home/$USER/.ssh/auth_sock"

           ${optionalString cfg.enableYazi ''
            # yazi
            function yy() {
              local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
              yazi "$@" --cwd-file="$tmp"
              if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
                cd -- "$cwd"
              fi
              rm -f -- "$tmp"
            }
          ''}
        '';
      autocd = true;
      dotDir = ".config/zsh";
      defaultKeymap = "emacs";
      autosuggestion.enable = true;
      enableCompletion = true;
      history = {
        ignoreDups = true;
        extended = true;
        save = 1000000;
        size = 1000000;
        share = true;
      };
      shellAliases = lib.mapAttrs (_: lib.mkOverride 900) config.home.shellAliases;
      plugins = [
        {
          name = "nix-zsh-completions";
          src = pkgs.nix-zsh-completions;
        }
        {
          name = "fzf-tab";
          src = pkgs.fetchFromGitHub {
            owner = "Aloxaf";
            repo = "fzf-tab";
            rev = "190500bf1de6a89416e2a74470d3b5cceab102ba";
            sha256 = "sha256-C6cE96YXyYP1RxpCLVtG1hcYLluplPLiIdkdo4HXN7Y=";
          };
          file = "fzf-tab.plugin.zsh";
        }
      ];
    };
  };
}
