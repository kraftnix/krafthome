{ self, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.khome.roles.basic;
  opts = self.inputs.extra-lib.lib.options;
  inherit (lib)
    mkEnableOption
    mkIf
    ;
in
{
  options.khome.roles.basic = {
    enable = opts.enable ''
      Enables basic role. Contains:
    '';
    graphical = opts.enable "include graphical programs";
    laptop = opts.enable "add useful tooling for laptops";
  };

  config = mkIf cfg.enable {
    # themes.extra.shellAliases = config.environment.shellAliases;
    home.packages = with pkgs; [
      attic-client # nix binary cache cli
    ];
    programs.zoxide.enable = true;
    khome.shell = {
      aliases.enable = true;
      atuin.enable = true;
      core-tools.enable = true;
      direnv.enable = true;
      editor = "nvim";
      fzf.enable = true;
      git.enable = true;
      misc.enable = true;
      nix-index.enable = true;
      nix-index.enableComma = true;
      ssh-rebind.enable = true;
      starship.enable = true;
      tmux.enable = true;
      yazi = {
        enable = true;
        theme = {
          name = "tokyo-night";
          src = pkgs.fetchFromGitHub {
            owner = "BennyOe";
            repo = "tokyo-night.yazi";
            rev = "024fb096821e7d2f9d09a338f088918d8cfadf34";
            hash = "sha256-IhCwP5v0qbuanjfMRbk/Uatu31rPNVChJn5Y9c5KWYQ=";
          };
        };
        plugins.bookmarks.enable = true;
        # plugins.mime.enable = true;
      };
      zsh.enable = true;
    };
    khome.browsers = {
      firefox.enable = true;
      tor.enable = true;
    };
    khome.misc = {
      sound.enable = true;
      keepass.enable = true;
    };
    khome.nushell.enable = true;
    khome.desktop = mkIf cfg.graphical {
      misc.enable = true;
      terminals = {
        wezterm.simple = true;
        alacritty.enable = true;
      };
      services.poweralertd.enable = cfg.laptop;
    };
  };
}
