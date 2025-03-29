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
      nu_plugin_explore = "sha256-oxMqJmQMc7Ns/Nt7vjZFx6vs0mmh3hOIv8BtopZ2s6Y=";
      # nu_plugin_dialog = "sha256-nbSbQ1DEBlT5ZqYgj+1Z4LU4t1833chPWxKMmCe4yAI="; # failed to load manifest
      nu_plugin_dbus = "sha256-7pD5LA1ytO7VqFnHwgf7vW9eS3olnZBgdsj+rmcHkbU=";
      nu_plugin_file = "sha256-s2Sw8NDVJZoZsnNeGGCXb64WFb3ivO9TxBYFcjLVOZI=";
      nu_plugin_port_list = "sha256-LicKxycLeBcD8NBwLvMttAS3rNkpaiealMmGZZ6d/HQ=";
      nu_plugin_prometheus = "sha256-LwVGBm+2j9bxa1Np5l77BgET+CytG10GDeUvbx+tGAU=";
      nu_plugin_skim = "sha256-5KwosdiWc7K+35d06lvFHaPP52d7ru7tjMG+X9H5oCQ=";
    };
  getSources = prev: prev.callPackage (import ./_sources/generated.nix) { };
  yaziPluginsSources =
    prev: sources:
    listToAttrs (
      map (plugin: nameValuePair (replaceStrings [ "." ] [ "-" ] plugin) sources.${plugin}.src) [
        "bookmarks.yazi"
        "glow.yazi"
        "fg.yazi"
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
      "hide-preview"
      "max-preview"
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
