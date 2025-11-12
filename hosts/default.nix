args@{
  self,
  inputs,
  ...
}:
{
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
        (
          { pkgs, lib, ... }:
          {
            stylix.image =
              lib.mkDefault
                self.packages.${pkgs.stdenv.hostPlatform.system}.stylix-default-wallpaper;
          }
        )
        inputs.home.nixosModules.home-manager
        inputs.provision.inputs.disko.nixosModules.disko
        self.nixosModules.home-manager-integration
        self.nixosModules.khomeOverlays
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
    overlays = [
      self.overlays.default
      self.overlays.workarounds
      inputs.nur.overlays.default
    ]
    ++ self.overlaysLists.core;
    specialArgs = {
      inherit self;
      inherit (self)
        inputs
        nixosModules
        profiles
        hmProfiles
        homeManagerModules
        ;
    };
  };

  perSystem =
    { ... }:
    {
      channels = {
        nixpkgs.config.permittedInsecurePackages = [
          "jitsi-meet-1.0.8792" # element
        ];
        stable.config.permittedInsecurePackages = [ ];
      };
    };
}
