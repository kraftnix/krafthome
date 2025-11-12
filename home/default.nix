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
    files.firejail = ../nixosModules/security/firejail/home.nix;
    files.security = ../nixosModules/security/home.nix;
  };

  flake.externalHomeModules = [
    inputs.stylix.homeModules.stylix
    inputs.niri.homeModules.niri
  ];

  flake.hmProfiles = inputs.provision.lib.nix.rakeLeaves ./profiles // {
    vim = import ./vim args;
    nushell = import ./nushell args;
  };

  flake.overlays = {
    misc-fixes = final: prev: {
      vimPlugins = prev.vimPlugins // {
        nvim-spectre =
          self.channels.${final.stdenv.hostPlatform.system}.stable.pkgs.vimPlugins.nvim-spectre;
      };
    };
  };
  flake.overlaysLists = {
    core = with self.overlays; [
      nushellPlugins
      yaziPlugins
      misc-fixes
      inputs.elewrap.overlays.default
    ];
  };

  perSystem =
    sargs@{ self', ... }:
    {
      vimPlugins = self'.packagesGroups.vimPlugins;
    };
}
