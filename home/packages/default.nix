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
      nu_plugin_dbus = "sha256-6T2DiJpMtt5VshjU2TaVjWzPO7aGlzYjtVO+HMhwKX0=";
      # nu_plugin_file = "";
      nu_plugin_port_list = "sha256-BJg3gNocQThwfn4Lp+deXJk3zdKpv5AYDm4Y5hRlX3k=";
      nu_plugin_prometheus = "sha256-OSNaYffOJZxJriSvbDCNeCWEKorZsz3z4wdrtFhYF7E=";
      nu_plugin_skim = "sha256-CYfI1yy28eW/p67V6M9H6g0UaQQoqG3pyv7Q7AFJZJ8=";
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
