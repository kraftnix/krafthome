localFlake @ {
  self,
  inputs,
  ...
}: {
  imports = [
    ./hosts
    ./packages
    ./flakeModules/vim-plugins.nix
    ./lib
    (import ./site.nix localFlake)
    inputs.devshell.flakeModule
    inputs.git-hooks-nix.flakeModule
  ];

  ## Devshells
  perSystem = {
    config,
    pkgs,
    ...
  }: {
    devshells.default = {
      imports = [inputs.provision.devshellModules.provision];
      provision.enable = true;
      provision.nvfetcher.enable = true;
      provision.nvfetcher.sources.nixos.baseDir = "./nixos/packages";
      provision.nvfetcher.sources.home.baseDir = "./home/packages";
      devshell.startup.pre-commit = {
        text = config.pre-commit.installationScript;
      };
      packages = with pkgs;
        [
          just
          openssh
        ]
        ++ config.pre-commit.settings.enabledPackages;
    };
    pre-commit = {
      settings.hooks = {
        alejandra.enable = true;
        nil.enable = true;
      };
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
