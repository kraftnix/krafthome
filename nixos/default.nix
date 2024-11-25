args @ {
  self,
  inputs,
  ...
}: {
  imports = [
    ./hosts
    ./packages
  ];

  #flake.profiles = self.lib.importDirToAttrs ./profiles;

  # flake.users = {
  #   media = import ./users/media.nix;
  #   devUser = import ./users/dev-user.nix;
  # };

  # flake.nixosModulesFlakeArgs = args;
  flake.auto-import.enable = true;
  flake.auto-import.nixos.dir = ./modules;
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
