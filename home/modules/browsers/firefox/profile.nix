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
      order = mkOption {
        description = "The order the search engines are listed in, ignored if empty list.";
        default = [ config.search.default ];
        type = with types; listOf str;
      };
      privateDefault = mkOption {
        description = "default search engine in private window";
        default = config.search.default;
        type = types.str;
      };
      engines = mkOption {
        description = "set search engines in `programs.firefox.profiles.<name>.search.engines`";
        default = { };
        example = {
          Bing.metaData.hidden = true;
          Google.metaData.hidden = true;
        };
        type = (pkgs.formats.json { }).type;
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

  config.search.engines = {
    Bing = mkDefault {
      metaData.hidden = true;
    };
    Google = mkDefault {
      metaData.hidden = true;
    };
    "Nix Packages" = {
      urls = [
        {
          template = "https://search.nixos.org/packages";
          params = [
            {
              name = "type";
              value = "packages";
            }
            {
              name = "query";
              value = "{searchTerms}";
            }
          ];
        }
      ];
      icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
      definedAliases = [ "@np" ];
    };
    "NixOS Wiki" = {
      urls = [ { template = "https://wiki.nixos.org/w/index.php?search={searchTerms}"; } ];
      iconUpdateURL = "https://wiki.nixos.org/nixos.png";
      updateInterval = 24 * 60 * 60 * 1000;
      definedAliases = [ "@nw" ];
    };
  };
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
}
