localFlake:
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
    mkMerge
    mkOption
    types
    ;
  cfg = config.khome.nvim;
in
{
  imports = [ localFlake.inputs.kraftnvim.homeModules.default ];
  options = {
    khome.nvim = {
      enable = mkEnableOption "enable adding neovim configuration form kraftnvim";
      defaultPackage = mkOption {
        description = "package to set as default (as `nvim` package)";
        default = "kraftnvim";
        type = types.str;
      };
      linkConfig = mkOption {
        description = "recursively link lua config to `.config/nvim`";
        default = true;
        type = types.bool;
      };
      packagesToAdd = mkOption {
        description = "extra package names to add to `kraftnvim.packageNames`";
        default = [
          "kraftnvim"
          "kraftnvimLocal"
          "kraftnvimStable"
          "kraftnvimStableLocal"
        ];
        type = with types; listOf str;
      };
      settings = mkOption {
        default = { };
        description = "extra configuration to add to nixCats home module `kraftnvim`";
        type = with types; attrsOf anything;
      };
    };
  };
  config = mkIf cfg.enable {
    kraftnvim = mkMerge [
      {
        enable = true;
        packageNames = cfg.packagesToAdd;
        packageDefinitions.merge.${cfg.defaultPackage} = (
          { pkgs, ... }:
          {
            settings.aliases = [ "nvim" ];
          }
        );
      }
      cfg.settings
    ];
    # keep a static copy of nvim, and replace with a writable version each time
    # somewhat required for nvim-scissors needing a writable snippets dir to be nice to user
    xdg.configFile."nvim_static" = {
      recursive = true;
      source = config.kraftnvim.luaPath;
      onChange = ''
        rm -rf ${config.xdg.configHome}/nvim
        cp -r ${config.xdg.configHome}/nvim_static ${config.xdg.configHome}/nvim
        chmod -R u+w ${config.xdg.configHome}/nvim
      '';
    };
  };
}
