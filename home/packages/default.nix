{
  self,
  inputs,
  lib,
  ...
}:
let
  inherit (lib)
    listToAttrs
    mapAttrs
    nameValuePair
    replaceStrings
    ;

  importNuPlugin =
    prev: sources: name: cargoHash:
    prev.callPackage (import ./nu_plugins/${name}.nix sources.${name} cargoHash) { };

  nuPlugins =
    prev: sources:
    mapAttrs (importNuPlugin prev sources) {
      nu_plugin_explore = "sha256-YqmU+j1dcw9YN0p3h+s4hJpt1O6z6EYrSj8lApQX93o=";
      # nu_plugin_dialog = "sha256-nbSbQ1DEBlT5ZqYgj+1Z4LU4t1833chPWxKMmCe4yAI="; # failed to load manifest
      # nu_plugin_dbus = "sha256-7pD5LA1ytO7VqFnHwgf7vW9eS3olnZBgdsj+rmcHkbU=";
      # nu_plugin_file = "sha256-djqW120VLj7VByLHlQcKBEOmHeD74TNSWfjbeMfWmQg="; # upstream tries to use a binary in build script
      nu_plugin_prometheus = "sha256-0UPG8I4Iqt/uEbV4DFxYEPk4gEdPAETT8D50kPdMhEw=";
      # nu_plugin_skim = "sha256-HyMDgs41pRSUBg30F3IWU2hWSE8S41aLxWMp06gN0zk="; # now upstream
    };
  getSources = prev: prev.callPackage (import ./_sources/generated.nix) { };
  yaziPluginsSources =
    prev: sources:
    listToAttrs (
      map (plugin: nameValuePair (replaceStrings [ "." ] [ "-" ] plugin) sources.${plugin}.src) [
        "bookmarks.yazi"
        "fg.yazi"
        "what-size.yazi"
        "wl-clipboard.yazi"
        "open-with-cmd.yazi"
        # "whoosh.yazi"
        "gvfs.yazi"
        "searchjump.yazi"
        "officialPluginsSource"
      ]
    );

  renameNushellPlugins = lib.mapAttrs' (
    name: plugin: lib.nameValuePair (lib.replaceStrings [ "nu_plugin_" ] [ "" ] name) plugin
  );
  nushellPlugins' = prev: nuPlugins prev (getSources prev);
  nushellPlugins = prev: renameNushellPlugins (nushellPlugins' prev);
  renameYaziPlugins = lib.mapAttrs' (
    name: plugin: lib.nameValuePair (lib.replaceStrings [ "-yazi" ] [ "" ] name) plugin
  );
  yaziPlugins' = prev: yaziPluginsSources prev (getSources prev);
  getOfficialNushellPlugin =
    prev: plugin:
    prev.symlinkJoin {
      name = "${plugin}.yazi";
      paths = [ "${(yaziPlugins' prev).officialPluginsSource}/${plugin}.yazi" ];
    };
  yaziPlugins =
    prev:
    renameYaziPlugins (yaziPlugins' prev)
    // (lib.genAttrs [
      "chmod"
      "toggle-pane"
      "mime-ext"
      "mount"
      "smart-enter"
    ] (getOfficialNushellPlugin prev));
in
{
  flake.overlays = {
    nushellPlugins = final: prev: {
      nushellPlugins = prev.nushellPlugins // (nushellPlugins prev);
    };
    yaziPlugins = final: prev: {
      yaziPlugins = (prev.yaziPlugins or { }) // (yaziPlugins prev);
    };
  };

  perSystem =
    { pkgs, ... }:
    {
      packagesGroups = {
        nushellPlugins = nushellPlugins pkgs;
        yaziPlugins = yaziPlugins pkgs;
      };
    };
}
