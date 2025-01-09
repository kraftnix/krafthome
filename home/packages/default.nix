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
      nu_plugin_explore = "sha256-560ULTbfvxoAiCBRkAOmFhFmNxe9kH110hvOOvXIjvI=";
      # nu_plugin_dialog = ""; # required cargo 1.38
      nu_plugin_dbus = "sha256-dhtzN9wnDFx5+0oJOshM0UuMOHnl//oJLdd3yNINuZw=";
      # nu_plugin_file = "";
      nu_plugin_port_list = "sha256-z1sjlCjirXhn8fI8ABRGjdR+jzjMRN9MXqd+4SfKPSs=";
      nu_plugin_prometheus = "sha256-OSNaYffOJZxJriSvbDCNeCWEKorZsz3z4wdrtFhYF7E=";
      nu_plugin_skim = "sha256-+wmPnNNaGvPn7dPEFIBCkNkTDcsILzKRG34GlKhkDxc=";
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
