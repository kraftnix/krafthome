args:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.khome.browsers.firefox;
  inherit (lib)
    flatten
    mkDefault
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    unique
    types
    ;
in
{
  imports = [
    ./extensions.nix
    ./policies.nix
    ./profile-desktop-items.nix
    ./proxies.nix
    ./settings.nix
  ];

  options.khome.browsers.firefox = {
    enable = mkEnableOption "enable firefox browser";
    package = mkOption {
      type = types.package;
      description = "final package used for firefox";
      default = pkgs.firefox-wayland;
    };
    forceWayland = mkEnableOption "force wayland chromium flags";
    profiles = mkOption {
      description = "wrapped around `programs.firefox.profiles` where extension and setting profiles can be defined";
      default = { };
      type = types.attrsOf (
        types.submoduleWith {
          specialArgs.pkgs = pkgs;
          specialArgs.toplevel = cfg;
          modules = [ ./profile.nix ];
        }
      );
    };
  };

  config = mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      package = cfg.package;
      policies = cfg.policies;
      profiles = builtins.mapAttrs (name: pcfg: {
        inherit (pcfg) id;
        extensions = pcfg.finalExtensions;
        search = mkIf pcfg.search.enable {
          enable = true;
          inherit (pcfg.search)
            force
            default
            privateDefault
            order
            engines
            ;
        };
        settings = mkMerge [
          pcfg.finalSettings
          (mkIf pcfg.autoEnableExtensions {
            "extensions.autoDisableScopes" = 0;
          })
        ];
      }) cfg.profiles;
    };
    home.sessionVariables = mkIf cfg.forceWayland {
      MOZ_ENABLE_WAYLAND = 1;
    };
  };
}
