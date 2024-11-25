args: {
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.khome.browsers.firefox;
  inherit
    (lib)
    flatten
    mkDefault
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    unique
    types
    ;
  inherit
    (types)
    attrsOf
    int
    listOf
    nullOr
    package
    str
    submodule
    raw
    ;
in {
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
    };
    forceWayland = mkEnableOption "force wayland chromium flags";
    profiles = mkOption {
      description = "wrapped around `programs.firefox.profiles` where extension and setting profiles can be defined";
      default = {};
      type = types.attrsOf (types.submodule ({config, ...}: {
        config.finalSettings = mkMerge ([
            config.settings
            (mkIf (config.theme != null) {
              "extensions.activeThemeID" = config.theme;
            })
            (mkIf (config.proxyServer != null)
              (lib.mapAttrs (_: lib.mkDefault) (cfg.proxies.${config.proxyServer}.__opts))
              // (lib.optionalAttrs (config.proxyExceptions != []) {
                "network.proxy.no_proxies_on" = builtins.concatStringsSep "," config.proxyExceptions;
              }))
          ]
          ++ (map (profile: cfg.presets.settings.${profile}) config.presets.settings));
        options = {
          id = mkOption {
            type = int;
            default = 0;
            description = "numbered id of profile (required + must be unique)";
          };
          theme = mkOption {
            type = nullOr str;
            description = "theme to set, default: none";
            default = null;
          };
          settings = mkOption {
            type = raw;
            description = "settings for firefox profile (combined with `profile.settings`)";
            default = {};
          };
          finalSettings = mkOption {
            type = types.attrsOf raw;
            description = "final settings for firefox profile";
            default = {};
          };
          proxyServer = mkOption {
            default = null;
            type = nullOr str;
            description = "which proxy server to use for profile, must refere to a proxy server defined in `khome.browsers.firefox.proxies`, default: null / none";
          };
          proxyExceptions = mkOption {
            default = [];
            type = listOf str;
            description = "list of exceptions for defined proxy server";
          };
          extensions = mkOption {
            type = listOf package;
            description = "final extensions for firefox profile";
            default = [];
          };
          finalExtensions = mkOption {
            type = listOf package;
            readOnly = true;
            description = "final settings for firefox profile";
            default = unique (flatten ([
                config.extensions
              ]
              ++ (map (profile: cfg.presets.extensions.${profile}) config.presets.extensions)));
          };
          presets = {
            settings = mkOption {
              type = listOf str;
              description = "settings profiles to enable for profile";
              default = [];
            };
            extensions = mkOption {
              type = listOf str;
              description = "settings profiles to enable for profile";
              default = [];
            };
          };
        };
      }));
    };
  };

  config = mkIf cfg.enable {
    khome.browsers.firefox.package = mkDefault (
      pkgs.wrapFirefox pkgs.firefox-unwrapped {
        extraPolicies = cfg.policies;
      }
    );
    programs.firefox = {
      enable = true;
      package = cfg.package;
      profiles =
        builtins.mapAttrs (name: pcfg: {
          inherit (pcfg) id;
          extensions = pcfg.finalExtensions;
          settings = pcfg.finalSettings;
        })
        cfg.profiles;
    };
    home.sessionVariables = mkIf cfg.forceWayland {
      MOZ_ENABLE_WAYLAND = 1;
    };
  };
}
