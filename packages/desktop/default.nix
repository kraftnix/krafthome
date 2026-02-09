nixpkgs:
let
  libbluray-full-mine = nixpkgs.libbluray.override {
    inherit (nixpkgs) libaacs libbdplus;
    withAACS = true;
    withBDplus = true;
  };
in
{
  inherit libbluray-full-mine;
  mpv-bluray = nixpkgs.mpv-unwrapped.override {
    libbluray = libbluray-full-mine;
    bluraySupport = true;
  };
  firefox-priv-defaults-wayland = nixpkgs.wrapFirefox nixpkgs.firefox-unwrapped {
    extraPolicies = {
      CaptivePortal = false;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DisableFirefoxAccounts = true;
      DontCheckDefaultBrowser = true;
      FirefoxHome = {
        Pocket = false;
        Snippets = false;
      };
      UserMessaging = {
        ExtensionRecommendations = false;
        SkipOnboarding = true;
      };
      SearchEngines = {
        Remove = [
          "google"
          "amazon"
          "bing"
          "ebay"
          "wikipedia"
        ];
      };
    };
  };
}
