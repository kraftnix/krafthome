{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  inherit
    (lib)
    mkIf
    mkMerge
    mkOption
    types
    ;

  cfg = config.programs.lazy-neovim;
in {
  options.programs.lazy-neovim = mkOption {
    description = "Lazy Neovim module for home-manager.";
    type = types.submoduleWith {
      modules = [
        {config._module.args.pkgs = pkgs;}
        {config._module.args.inputs = inputs;}
        ./options.nix
      ];
    };
    default = {};
  };

  config = mkIf (cfg.enable == true) {
    home.packages = [pkgs.nixpkgs-fmt pkgs.alejandra]; # TODO(cleanup): move elsewhere
    # home.activation.neovim-copy = lib.mkForce (lib.hm.dag.entryBetween [ "reloadSystemd" ] [ ] "");
    programs.neovim = {
      inherit (cfg) enable extraPackages;
    };
    home.file = mkMerge [
      cfg.__pluginFileLinks
      cfg.__neovimFileLinks
    ];
    # breaks neovim # E79
    stylix.targets.kde.enable = false;
  };
}
