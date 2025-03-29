args@{
  self,
  inputs,
  ...
}:
{
  imports = [ ./packages ];
  debug = true;

  flake.auto-import.homeManager = {
    addTo.modules = true;
    flakeArgs = args;
    dir = ./modules;
    modules.firejail = ../nixosModules/security/firejail/home.nix;
    modules.security = ../nixosModules/security/home.nix;
  };

  flake.externalHomeModules = [
    # inputs.stylix.homeManagerModules.stylix
    inputs.anyrun.homeManagerModules.default
  ];

  flake.hmProfiles = inputs.provision.lib.nix.rakeLeaves ./profiles // {
    vim = import ./vim args;
    nushell = import ./nushell args;
  };

  flake.overlays = {
    # anyrun = inputs.anyrun.overlays.default;
    anyrun = final: prev: {
      inherit (inputs.anyrun.packages.${final.system}) anyrun anyrun-with-all-plugins;
    };
    misc-fixes = final: prev: {
      vimPlugins = prev.vimPlugins // {
        nvim-spectre = self.channels.${final.system}.stable.pkgs.vimPlugins.nvim-spectre;
      };
      # logseq removed from unstable: https://github.com/NixOS/nixpkgs/issues/389011
      inherit (final.channels.stable.pkgs) logseq;
    };
    wezterm-upstream = final: prev: {
      wezterm-upstream = inputs.wezterm.packages.${final.system}.default;
    };
  };
  flake.overlaysLists = {
    core = with self.overlays; [
      anyrun
      nushellPlugins
      yaziPlugins
      misc-fixes
      wezterm-upstream
      inputs.elewrap.overlays.default
    ];
  };

  perSystem =
    sargs@{ self', ... }:
    {
      vimPlugins = self'.packagesGroups.vimPlugins;
    };
}
