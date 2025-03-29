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
        Homepage.StartPage = mkOption {
          description = "Home Startpage";
          type = types.str;
          default = "previous-session";
        };
        OverrideFirstRunPage = mkOption {
          description = "First Run Page override";
          type = types.str;
          default = "";
        };
        FirefoxSuggest = mkOption {
          description = "Disable annoying suggestions";
          type = types.raw;
          default = {
            WebSuggestions = false;
            SponsoredSuggestions = false;
            ImproveSuggest = false;
          };
        };
        FirefoxHome = mkOption {
          description = "Firefox Home options";
          type = types.raw;
          default = {
            Search = true;
            TopSites = false;
            SponsoredTopSites = false;
            Highlights = false;
            Pocket = false;
            SponsoredPocket = false;
            Snippets = false;
          };
        };
        ExtensionSettings = mkOption {
          description = "Attempt disable stupid search engines";
          type = types.attrsOf types.raw;
          default = {
            "amazon@search.mozilla.org".installation_mode = "blocked";
            "bing@search.mozilla.org".installation_mode = "blocked";
            "ebay@search.mozilla.org".installation_mode = "blocked";
            "ecosia@search.mozilla.org".installation_mode = "blocked";
            "google@search.mozilla.org".installation_mode = "blocked";
          };
        };
        EnableTrackingProtection = mkOption {
          description = "Enable tracking protection";
          type = types.raw;
          default = {
            Value = true;
            Cryptomining = true;
            Fingerprinting = true;
          };
        };
        UserMessaging = mkOption {
          description = "User Messaging on start";
          type = types.raw;
          default = {
            ExtensionRecommendations = false;
            UrlbarInterventions = false;
            SkipOnboarding = true;
          };
        };
        SearchEngines = mkOption {
          description = "Search Engines options";
          type = types.raw;
          default = {
            Default = "ddg";
            Remove = [
              "google"
              "amazon"
              "bing"
              "ebay"
            ];
          };
        };
      };
    };
    default = { };
    description = "policies to use for building firefox, only applies when `khome.browser.firefox.package` is not overridden";
  };
}
