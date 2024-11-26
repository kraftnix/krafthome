localFlake:
{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib)
    attrValues
    mapAttrsToList
    mkEnableOption
    mkIf
    mkOption
    mkMerge
    types
    ;
  cfg = config.home.firejail;
  homeFirejailModule =
    { config, ... }:
    {
      config._module.args.descriptions.enable = "enable home-manager firejail integration";
      options = {
        addAllToHomePackages = mkEnableOption "add single firejail package with all firejail wrapped binaries to `home.packages`";
        addToHomePackages = mkEnableOption "add firejail wrapped binaries to `home.packages`";
      };
    };
in
{
  options.home.firejail = mkOption {
    default = { };
    description = ''
      Define firejail binaries in home-manager configurations, optionally add wrappers to home.packages.

      `programs.firejail` will need to be enabled on the host as the base firejail security wrapper needs installation.
    '';
    type = types.submoduleWith {
      modules = [
        ./submodule.nix
        homeFirejailModule
        { config._module.args.pkgs = pkgs; }
      ];
    };
  };

  config = mkIf cfg.enable (mkMerge [
    { home.packages = mkIf cfg.addAllToHomePackages [ cfg.allBinaries ]; }
    { home.packages = mkIf cfg.addToHomePackages (attrValues cfg.binaries); }
  ]);
}
