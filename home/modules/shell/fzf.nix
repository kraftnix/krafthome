args:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    optionals
    mkOption
    types
    ;
  cfg = config.khome.shell.fzf;
  theme = config.lib.base16.getTheme "fzf";
in
{
  options.khome.shell.fzf = {
    enable = mkEnableOption "enable fzf";
    height = mkOption {
      type = types.str;
      default = "40%";
      description = "height of fzf window";
    };
    enableBackground = mkEnableOption "enable opacity" // {
      default = config.khome.themes.opacity < 1;
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      bat
      eza
      fd
    ];

    home.sessionVariables = {
      FZF_TMUX_HEIGHT = cfg.height;
      FZF_COMPLETION_OPTS = ''--preview='bat {} --theme="base16" --style="numbers" --color=always 2>/dev/null || lsd {} -l --color=always' '';
    };

    stylix.targets.fzf.enable = config.khome.themes.enable;
    programs.fzf = {
      enable = true;
      defaultCommand = ''fd --type f'';
      defaultOptions = [
        "--ansi"
        "--height ${cfg.height}"
        "--bind=tab:down,change:top,ctrl-s:toggle --cycle"
      ]
      ++ optionals config.khome.themes.enable (
        with theme;
        [
          # "${optionalString cfg.enableBackground "--color=bg+:#${base01},bg:#${base00}"}"
          # "--color=spinner:#${base0C},hl:#${base0D}"
          # "--color=fg:#${base04},header:#${base0D},info:#${base0A},pointer:#${base0C}"
          # "--color=marker:#${base0C},fg+:#${base06},prompt:#${base08},hl+:#${base08}"
        ]
      );

      historyWidgetOptions = [ "--exact" ];

      fileWidgetCommand = "fd --type f";
      fileWidgetOptions = [ ''--preview='bat {} --theme="base16" --color=always --style="numbers" ' '' ];

      changeDirWidgetCommand = "fd --type d .";
      changeDirWidgetOptions = [ ''--preview='lsd {} -l --color=always' '' ];
    };
  };
}
