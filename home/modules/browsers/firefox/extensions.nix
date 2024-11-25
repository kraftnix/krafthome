{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.khome.browsers.firefox;
  inherit
    (lib)
    attrValues
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in {
  options.khome.browsers.firefox.presets = {
    enableDefaultExtensions = mkEnableOption "enable default extension preset groups" // {default = true;};
    extensions = mkOption {
      type = with types; attrsOf (listOf package);
      default = {};
      description = "extension groups / profiles for enablement in firefox profiles.";
    };
  };

  config = mkIf cfg.presets.enableDefaultExtensions {
    khome.browsers.firefox.presets.extensions = with pkgs.nur.repos.rycee.firefox-addons; rec {
      core-privacy = [
        ublock-origin # adblocking
        # noscript            # disable javascript
        privacy-redirect # redirect youtube/twitter/reddit to privacy alternatives
        link-cleaner # remove utm + other tracking in links
        cookie-autodelete # auto-delete cookies on page leave
      ];
      core-other = [
        vimium # vim in browser (simple)
        darkreader # dark mode every page
      ];
      basic = core-privacy ++ core-other;
      main-browser =
        basic
        ++ [
          tridactyl # vim in browser (advanced)
          multi-account-containers # firefox containers
          foxyproxy-standard # proxying (socks/http etc.)
          floccus # bookmarks via webdav/nextcloud
        ];
      media = basic ++ [torrent-control];
      home = media ++ [bitwarden];
      rycee-addons = pkgs.nur.repos.rycee.firefox-addons;
      all-rycee-addons = attrValues pkgs.nur.repos.rycee.firefox-addons;
    };
  };
}
