{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.khome.browsers.firefox;
  inherit
    (lib)
    mkEnableOption
    mkIf
    optionalString
    mkOption
    types
    ;
in {
  options.khome.browsers.firefox.addProfileDesktopItems =
    mkEnableOption ''
      Make a desktop entry for each firefox profile.
    ''
    // {default = true;};

  config = mkIf (cfg.enable && cfg.addProfileDesktopItems) {
    # create .desktop files for each firefox profile (except default)
    home.packages =
      lib.mapAttrsToList
      (name: attrs:
        pkgs.makeDesktopItem {
          name = "firefox-${name}";
          startupWMClass = "firefox-${name}";
          comment = "Firefox (${name})";
          #desktopName = "Firefox (${name})";
          desktopName = "${name}: firefox";
          # TODO: check if forcing env is still required
          # need to force wayland here for extra profiles? they don't see to take in above home.sessionVariabes
          exec = "${optionalString cfg.forceWayland "env MOZ_ENABLE_WAYLAND=1 XDG_SESSION_TYPE=wayland "}${config.programs.firefox.package}/bin/firefox --name firefox-${name} -P ${name} %U";
          icon = "firefox";
          genericName = "Web Browser";
          categories = ["Network" "WebBrowser"];
          mimeTypes = [
            "text/html"
            "text/xml"
            "application/xhtml+xml"
            "application/vnd.mozilla.xul+xml"
            "x-scheme-handler/http"
            "x-scheme-handler/https"
            "x-scheme-handler/ftp"
          ];
        })
      (lib.filterAttrs (n: v: n != "default") config.programs.firefox.profiles);
  };
}
