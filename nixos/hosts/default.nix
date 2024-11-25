args @ {
  self,
  inputs,
  ...
}: {
  imports = inputs.provision.auto-import.flake.all;

  flake.hosts.hostsDir = ./.;
  flake.hosts.defaults = {
    inherit self;
    system = "x86_64-linux";
    modules =
      inputs.provision.auto-import.nixos.all
      ++ self.auto-import.nixos.all
      ++ self.externalModules
      ++ [
        {stylix.image = ../../home/modules/themes/wallpaper.jpg;}
        inputs.home.nixosModules.home-manager
        inputs.provision.inputs.disko.nixosModules.disko
        self.nixosModules.home-manager-integration
        self.nixosModules.khomeOverlays
        # inputs.nixos-hardware.nixosModules.common-amd-gpu
        # inputs.nix-index-database.nixosModules.nix-index
        {
          home-manager.sharedModules =
            self.auto-import.homeManager.all
            ++ self.externalHomeModules
            ++ [
              inputs.provision.homeManagerModules.provision-scripts
              # inputs.nix-index-database.hmModules.nix-index
            ];
        }
      ];
    overlays =
      [
        self.overlays.default
        # (final: prev: {
        #   # inherit (self.channels.${final.system}.stable.pkgs) logseq;
        #  })
        inputs.nur.overlay
      ]
      ++ self.overlaysLists.core;
    specialArgs = {
      inherit self;
      inherit (self) inputs nixosModules profiles hmProfiles homeManagerModules;
    };
  };

  perSystem = {...}: {
    channels = {
      nixpkgs.config.permittedInsecurePackages = [
        "electron-28.3.3"
        "electron-27.3.11"
      ];
      stable = {};
    };
  };
}
