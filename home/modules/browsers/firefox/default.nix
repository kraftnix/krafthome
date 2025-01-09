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
        types.submodule (
          { config, ... }:
          {
            config.finalSettings = mkMerge (
              [
                config.settings
                (mkIf (config.theme != null) {
                  "extensions.activeThemeID" = config.theme;
                })
                (
                  mkIf (config.proxyServer != null) (
                    lib.mapAttrs (_: lib.mkDefault) (cfg.proxies.${config.proxyServer}.__opts)
                  )
                  // (lib.optionalAttrs (config.proxyExceptions != [ ]) {
                    "network.proxy.no_proxies_on" = builtins.concatStringsSep "," config.proxyExceptions;
                  })
                )
              ]
              ++ (map (profile: cfg.presets.settings.${profile}) config.presets.settings)
            );
            options = {
              id = mkOption {
                type = types.int;
                default = 0;
                description = "numbered id of profile (required + must be unique)";
              };
              theme = mkOption {
                type = with types; nullOr str;
                description = "theme to set, default: none";
                default = null;
              };
              settings = mkOption {
                type = types.raw;
                description = "settings for firefox profile (combined with `profile.settings`)";
                default = { };
              };
              finalSettings = mkOption {
                type = types.attrsOf types.raw;
                description = "final settings for firefox profile";
                default = { };
              };
              proxyServer = mkOption {
                default = null;
                type = with types; nullOr str;
                description = "which proxy server to use for profile, must refere to a proxy server defined in `khome.browsers.firefox.proxies`, default: null / none";
              };
              proxyExceptions = mkOption {
                default = [ ];
                type = with types; listOf str;
                description = "list of exceptions for defined proxy server";
              };
              extensions = mkOption {
                type = with types; listOf package;
                description = "final extensions for firefox profile";
                default = [ ];
              };
              search = {
                enable = mkEnableOption "enable search engine integration" // {
                  default = true;
                };
                force = mkEnableOption "whether to force engines" // {
                  default = true;
                };
                default = mkOption {
                  description = "default search engine";
                  default = "DuckDuckGo";
                  type = types.str;
                };
                privateDefault = mkOption {
                  description = "default search engine in private window";
                  default = config.search.default;
                  type = types.str;
                };
                engines = mkOption {
                  description = "extra engines";
                  type = types.attrsOf types.raw;
                  default = {

                  };
                };
              };
              autoEnableExtensions = mkEnableOption "automatically enable extensions" // {
                default = true;
              };
              finalExtensions = mkOption {
                type = with types; listOf package;
                readOnly = true;
                description = "final settings for firefox profile";
                default = unique (
                  flatten (
                    [
                      config.extensions
                    ]
                    ++ (map (profile: cfg.presets.extensions.${profile}) config.presets.extensions)
                  )
                );
              };
              presets = {
                settings = mkOption {
                  type = with types; listOf str;
                  description = "settings profiles to enable for profile";
                  default = [ ];
                };
                extensions = mkOption {
                  type = with types; listOf str;
                  description = "settings profiles to enable for profile";
                  default = [ ];
                };
              };
            };
          }
        )
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
