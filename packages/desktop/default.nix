nixpkgs:
let
  libbluray-full = nixpkgs.libbluray.override {
    inherit (nixpkgs) libaacs libbdplus;
    withAACS = true;
    withBDplus = true;
  };
in
{
  libbluray = libbluray-full;
  mpv-bluray = nixpkgs.mpv-unwrapped.override {
    libbluray = libbluray-full;
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
