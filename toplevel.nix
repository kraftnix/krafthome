localFlake@{
  lib,
  self,
  inputs,
  ...
}:
{
  imports = [
    ./hosts
    ./packages
    ./flakeModules/vim-plugins.nix
    ./lib
    (import ./site.nix localFlake)
    inputs.provision.auto-import.flake.modules.provision.shells
  ];

  ## Devshells
  perSystem =
    {
      config,
      pkgs,
      ...
    }:
    {
      provision.enable = true;
      provision.enableDefaults = true;
      devshells.default = {
        provision.enable = true;
        provision.nvfetcher.enable = true;
        provision.nvfetcher.sources.nixos.baseDir = "./packages";
        provision.nvfetcher.sources.home.baseDir = "./home/packages";
        packages = with pkgs; [
          just
          openssh
        ];
      };
    };

  # flake.profiles = self.lib.importDirToAttrs ./profiles;
  flake.nixd.options.nixos = self.nixosConfigurations.dev-laptop.options;
  flake.nixd.options.home-manager = self.homeConfigurations.dev-user.options;
  # for LSP / nixd
  flake.homeConfigurations.dev-user = inputs.home.lib.homeManagerConfiguration {
    pkgs = self.nixosConfigurations.dev-laptop.pkgs;
    inherit (self.nixosConfigurations.dev-laptop.config.home-manager) extraSpecialArgs;
    # modules = (builtins.attrValues self.auto-import.homeManager.modules') ++ [
    modules = [
      inputs.stylix.homeModules.stylix
      {
        options.meta.doc = lib.mkOption { default = { }; };
        config.home.stateVersion = "23.11";
        config.home.username = "dev-user";
        config.home.homeDirectory = "/home/dev-user";
      }
    ];
  };

  ## Imports
  flake.auto-import.enable = true;
  flake.auto-import.nixos.dir = ./nixosModules;
  flake.auto-import.nixos.addTo.modules = true;
  flake.externalModules = [
    inputs.stylix.nixosModules.stylix
    inputs.elewrap.nixosModules.default
  ];
  flake.overlays = {
    workarounds = final: prev: {
      inherit (localFlake.inputs.stable.legacyPackages.${final.system})
        isd
        ;
    };
  };
  flake.nixosModules = {
    khomeOverlays = {
      nixpkgs.overlays = [
        (final: prev: {
          lib = prev.lib.extend (_: _: self.lib);
        })
        inputs.elewrap.overlays.default
      ];
    };

    home-manager-integration = {
      config.home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "bak";
        extraSpecialArgs = {
          inherit self inputs;
          inherit (self) hmProfiles homeModules;
        };
      };
    };
  };
}
