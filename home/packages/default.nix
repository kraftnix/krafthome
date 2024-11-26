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

  allVimPlugins =
    nixpkgs: sources:
    (import ./vim-plugin.nix nixpkgs sources [
      # "nvim-nu"
      "nvim-telescope-hop"
      "nvim-guess-indent"
      "neozoom-nvim"
      "sessions-nvim"
      "fm-nvim"
      "yazi-nvim"
      "portal-nvim"
      "magma-nvim"
      "telescope-tabs"
      "vim-doge"
      "commander-nvim"
      "one-small-step-for-vimkind-nvim"
      "telescope-all-recent"
      "telescope-menufacture"
      "telescope-env"
      "telescope-undo"
      "telescope-changes"
      "telescope-luasnip"
      "telescope-lazy-nvim"
      "telescope-live-grep-args-nvim"
      "cmp-nixpkgs"
      "easypick-nvim"
      "terminal-nvim"
      "browser-bookmarks-nvim"
      "middleclass-nvim"
      "nvim-devdocs"
    ]);

  importNuPlugin =
    prev: sources: name: cargoHash:
    prev.callPackage (import ./nu_plugins/${name}.nix sources.${name} cargoHash) { };

  nuPlugins =
    prev: sources:
    mapAttrs (importNuPlugin prev sources) {
      nu_plugin_explore = "sha256-ZIu94B9Gkgi0yCUP5dUZsyk2hwi88xr4mhbpGQ1TzDk=";
      # nu_plugin_dialog = ""; # required cargo 1.38
      nu_plugin_dbus = "sha256-6T2DiJpMtt5VshjU2TaVjWzPO7aGlzYjtVO+HMhwKX0=";
      # nu_plugin_file = "";
      nu_plugin_port_list = "sha256-BJg3gNocQThwfn4Lp+deXJk3zdKpv5AYDm4Y5hRlX3k=";
      nu_plugin_prometheus = "sha256-OSNaYffOJZxJriSvbDCNeCWEKorZsz3z4wdrtFhYF7E=";
      nu_plugin_skim = "sha256-Sjg1D9FiUYtX5gZVdeDtaRe8wcUMk2M8nkJXtcH48ww=";
    };
  getVimSources = prev: prev.callPackage (import ./_sources/generated.nix) { };

  vimPlugins = final: prev: allVimPlugins prev (getVimSources final);

  renamePlugins = lib.mapAttrs' (
    name: plugin: lib.nameValuePair (lib.replaceStrings [ "nu_plugin_" ] [ "" ] name) plugin
  );
  nushellPlugins' = prev: nuPlugins prev (getVimSources prev);
  nushellPlugins = prev: renamePlugins (nushellPlugins' prev);
in
{
  flake.overlays = {
    vimPlugins = final: prev: {
      vimPluginsSources = getVimSources prev;
      vimPlugins = prev.vimPlugins // (vimPlugins final prev);
    };
    nushellPlugins = final: prev: {
      nushellPlugins = prev.nushellPlugins // (nushellPlugins prev);
    };
  };

  perSystem =
    { pkgs, ... }:
    {
      packagesGroups = {
        vimPlugins = vimPlugins pkgs pkgs;
        nushellPlugins = nushellPlugins pkgs;
      };
    };
}
