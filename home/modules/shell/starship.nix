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
    mkOption
    types
    ;
  cfg = config.khome.shell.starship;
  theme = cfg.themes.${cfg.theme};
in
{
  options.khome.shell.starship = {
    enable = mkEnableOption "enable starship";
    theme = mkOption {
      type = types.str;
      description = "theme to use";
      default = "tokyo-night";
    };
    themes = mkOption {
      type = types.attrsOf types.raw;
      default = {
        gruvbox = {
          username = "[$user]($style)";
          hostname = "[@$hostname](bold bright-red) [|](bold bright-green) ";
          directory = "[$path]($style)[$read_only]($read_only_style) ";
        };
        tokyo-night = {
          username = "[$user](bold red)";
          hostname = "[@](bold yellow)[$hostname](bold bright-cyan) [|](bold bright-green) ";
          directory = "[$path](bold bright-cyan)[$read_only](bold bright-red) ";
        };
      };
      description = "themes for starship";
    };
  };

  config = mkIf cfg.enable {
    programs.starship = {
      enable = true;
      settings = {
        add_newline = false;
        format = "$all\$fill\$time\$line_break\$character";
        shell.disabled = false;
        time = {
          disabled = false;
          format = "$date [$time]($style)";
          time_format = "<%Y-%m-%d> 📅 <%T> ⏰";
        };
        cmd_duration = {
          min_time = 500;
          format = "took [$duration](bold yellow) ";
        };

        username = {
          show_always = true;
          format = theme.username;
        };
        hostname = {
          ssh_only = false;
          format = theme.hostname;
        };
        directory.format = theme.directory;

        nix_shell = {
          heuristic = true;
          impure_msg = "[impure](yellow)";
          pure_msg = "[pure](bold green)";
          unknown_msg = "[unknown](bold yellow)";
          format = "▶ [|](bold blue)[❄  $state( ($name))](bold blue)[|](bold blue) ";
          # impure_msg = "[impure shell](bold red)";
          # pure_msg = "[pure shell](bold green)";
          # unknown_msg = "[unknown shell](bold yellow)";
          # format = "via [☃️ $state( \($name\))](bold blue) ";
        };

        # Testing
        status = {
          symbol = "🎆{($status)}@";
          # success_symbol = "✔️ ";
          format = "[➜](bold) [$symbol$common_meaning$signal_name$maybe_int]($style) ";
          map_symbol = true;
          disabled = false;
        };

        # os = {
        #   disabled = false;
        #   format = "on [$symbol]($style)";
        # };
      };
    };
  };
}
