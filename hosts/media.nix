{
  imports = [./basic.nix];
  khome.users.media.enable = true;
  khome.users.media.home = {hmProfiles, ...}: {
    imports = [hmProfiles.themes.tokyo-night];
    khome.roles.basic = {
      enable = true;
      graphical = true;
    };
    khome.desktop.swayidle.enable = true;
    khome.desktop.swww.enable = true;
    khome.browsers.firefox = {
      enable = true;
      profiles = {
        default = {
          id = 0;
          presets.extensions = ["home"];
          proxyServer = "no-svg-wg-socks5-002";
          theme = "firefox-compact-dark@mozilla.org";
        };
        relaxed = {
          id = 1;
          presets.extensions = ["home"];
          proxyServer = "nl-ams-wg-socks5-006";
          proxyExceptions = [".home.testing"];
          theme = "firefox-alpenglow@mozilla.org";
        };
        calls = {
          id = 3;
          presets.extensions = ["basic"];
          proxyServer = "gb-lon-wg-socks5-003";
        };
      };
    };
    khome.desktop.apps.media = {
      enable = true;
      jellyfin = {
        mpvShim.enable = true;
        mediaPlayer = true;
      };
    };
  };
  system.stateVersion = "23.11";
}
