localFlake@{
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
    inputs.provision.flakeModules.provision-shells
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
        provision.nvfetcher.sources.nixos.baseDir = "./nixos/packages";
        provision.nvfetcher.sources.home.baseDir = "./home/packages";
        packages = with pkgs; [
          just
          openssh
        ];
      };
    };

  # flake.profiles = self.lib.importDirToAttrs ./profiles;

  ## Imports
  flake.auto-import.enable = true;
  flake.auto-import.nixos.dir = ./nixosModules;
  flake.auto-import.nixos.addTo.modules = true;
  flake.externalModules = [
    inputs.stylix.nixosModules.stylix
    inputs.elewrap.nixosModules.default
  ];
  flake.nixosModules = {
    khomeOverlays = {
      nixpkgs.overlays = [
        (final: prev: {
          lib = prev.lib.extend (_: _: self.lib);
          nix-fast-build = inputs.nix-fast-build.packages.${final.system}.nix-fast-build;
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
