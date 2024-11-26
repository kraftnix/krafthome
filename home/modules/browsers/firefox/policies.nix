{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.khome.browsers.firefox.policies;
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  mkEnableTrueOption = opt: mkEnableOption opt // { default = true; };
  ts = with types; [
    bool
    raw
    str
    int
    (listOf str)
  ];
in
{
  options.khome.browsers.firefox.policies = mkOption {
    type = types.submodule {
      freeformType = with types; attrsOf (oneOf ts);
      options = {
        CaptivePortal = mkEnableOption "enable Captive Portal";
        DisableFirefoxStudies = mkEnableTrueOption "disable firefox studies";
        DisablePocket = mkEnableTrueOption "disable pocket";
        DisableTelemetry = mkEnableTrueOption "disable telemetry";
        DisableFirefoxAccounts = mkEnableTrueOption "disable firefox accounts integration (unused feature)";
        DontCheckDefaultBrowser = mkEnableTrueOption "dont check for default browser (annoyance)";
        FirefoxHome = mkOption {
          description = "Firefox Home options";
          type = types.raw;
          default = {
            Pocket = false;
            Snippets = false;
          };
        };
        UserMessaging = mkOption {
          description = "User Messaging on start";
          type = types.raw;
          default = {
            ExtensionRecommendations = false;
            SkipOnboarding = true;
          };
        };
        SearchEngines = mkOption {
          description = "Search Engines options";
          type = types.raw;
          default = {
            Remove = [
              "Google"
              "Amazon.com"
              "Bing"
              "eBay"
            ];
          };
        };
      };
    };
    default = { };
    description = "policies to use for building firefox, only applies when `khome.browser.firefox.package` is not overridden";
  };
}
