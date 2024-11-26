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
    ;
  cfg = config.khome.shell.fish;
in
{
  options.khome.shell.fish = {
    enable = mkEnableOption "enable fish";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # rust alternatives
      fd # find alternative
      bat # cat alternative
      eza # ls alternative
      ripgrep # grep alternative
    ];

    # NOTE: must be enabled at system level for completions
    # environment.pathsToLink = [ "/share/fish" ];

    programs.fish = {
      enable = true;
      shellAliases = lib.mapAttrs (_: lib.mkOverride 900) config.home.shellAliases;
      plugins = [
        {
          name = "fzf";
          src = pkgs.fetchFromGitHub {
            owner = "jethrokuan";
            repo = "fzf";
            rev = "479fa67d7439b23095e01b64987ae79a91a4e283";
            sha256 = "sha256-28QW/WTLckR4lEfHv6dSotwkAKpNJFCShxmKFGQQ1Ew=";
          };
        }
      ];
    };
  };
}
