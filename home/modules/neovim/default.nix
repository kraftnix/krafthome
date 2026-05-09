localFlake:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkDefault
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
      aliasDefaultToNvim = mkOption {
        description = "Adds default kraftnvim package as shell alias for `nvim`";
        default = true;
        type = types.bool;
      };
      defaultPackage = mkOption {
        description = "package to set as default (as `nvim` package)";
        default = "kraftnvim";
        type = types.str;
      };
      packagesToAdd = mkOption {
        description = "extra package names to add to `kraftnvim.packageNames`";
        default = [
          "kraftnvim"
          "kraftnvim-minimal"
          # "kraftnvim-d2"
        ];
        type = with types; listOf str;
      };
      settings = mkOption {
        default = { };
        description = "extra configuration to add to nix-wrapper home module `kraftnvim`";
        type = with types; attrsOf anything;
      };
    };
  };
  config = mkIf cfg.enable {
    khome.shell.aliases.aliases = mkIf cfg.aliasDefaultToNvim {
      nvim = cfg.defaultPackage;
    };
    wrappers.kraftnvim = {
      enable = true;
      settings = mkMerge [
        cfg.settings
        {
          profile = mkDefault "full";
          languages.enableAll = mkDefault true;
        }
      ];
    };
  };
}
