{
  self,
  inputs,
  lib,
  ...
}:
let
  inherit (lib)
    mapAttrs
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
  getVimSources = prev: prev.callPackage (import ./_sources/generated.nix) { };

  renamePlugins = lib.mapAttrs' (
    name: plugin: lib.nameValuePair (lib.replaceStrings [ "nu_plugin_" ] [ "" ] name) plugin
  );
  nushellPlugins' = prev: nuPlugins prev (getVimSources prev);
  nushellPlugins = prev: renamePlugins (nushellPlugins' prev);
in
{
  flake.overlays = {
    nushellPlugins = final: prev: {
      nushellPlugins = prev.nushellPlugins // (nushellPlugins prev);
    };
  };

  perSystem =
    { pkgs, ... }:
    {
      packagesGroups = {
        nushellPlugins = nushellPlugins pkgs;
      };
    };
}
