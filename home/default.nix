args @ {
  self,
  inputs,
  ...
}: {
  imports = [./packages];
  debug = true;

  flake.auto-import.homeManager = {
    addTo.modules = true;
    flakeArgs = args;
    dir = ./modules;
    modules.firejail = ../nixos/modules/security/firejail/home.nix;
    modules.security = ../nixos/modules/security/home.nix;
  };

  flake.externalHomeModules = [
    # inputs.stylix.homeManagerModules.stylix
    inputs.anyrun.homeManagerModules.default
  ];

  flake.hmProfiles =
    inputs.provision.lib.nix.rakeLeaves ./profiles
    // {
      vim = import ./vim args;
      nushell = import ./nushell args;
    };

  flake.overlays = {
    # anyrun = inputs.anyrun.overlays.default;
    anyrun = final: prev: {
      inherit (inputs.anyrun.packages.${final.system}) anyrun anyrun-with-all-plugins;
    };
    misc-fixes = final: prev: {
      vimPlugins =
        prev.vimPlugins
        // {
          nvim-spectre = self.channels.${final.system}.stable.pkgs.vimPlugins.nvim-spectre;
        };
      tmux = inputs.provision.packages.${final.system}.tmux_3_3a;
      # jellyfin-mpv-shim fixes: https://github.com/NixOS/nixpkgs/pull/353833
      inherit (final.channels.stable.pkgs) jellyfin-mpv-shim;
    };
    tools = final: prev: {
      nix-fast-build = inputs.nix-fast-build.packages.${final.system}.nix-fast-build;
    };
    wezterm-upstream = final: prev: {
      wezterm-upstream = inputs.wezterm.packages.${final.system}.default;
    };
  };
  flake.overlaysLists = {
    core = with self.overlays; [
      anyrun
      vimPlugins
      nushellPlugins
      misc-fixes
      tools
      wezterm-upstream
      inputs.elewrap.overlays.default
    ];
  };

  perSystem = sargs @ {self', ...}: {
    vimPlugins = self'.packagesGroups.vimPlugins;
  };
}