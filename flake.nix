{
  description = "Kraftnix's desktop nixos + home-manager modules";

  # Core
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos.follows = "nixpkgs"; # TODO: remove
    stable.url = "github:nixos/nixpkgs/release-25.05";
    home.url = "github:nix-community/home-manager";
    home.inputs.nixpkgs.follows = "nixpkgs";
    systems.url = "github:nix-systems/default-linux";
  };

  ## Mine
  inputs = {
    kraftnvim.url = "github:kraftnix/kraftnvim";
    kraftnvim.inputs.nixpkgs.follows = "nixpkgs";

    provision.url = "github:kraftnix/provision-nix";
    provision.inputs = {
      nixpkgs.follows = "nixpkgs";
      nixpkgs-stable.follows = "stable";
    };
    extra-lib.follows = "provision/extra-lib";
    colmena.follows = "provision/colmena";
  };

  inputs = {
    elewrap.url = "github:oddlama/elewrap";
    elewrap.inputs.nixpkgs.follows = "nixpkgs";

    nur.url = "github:nix-community/NUR";

    niri.url = "github:sodiboo/niri-flake";
    niri.inputs = {
      nixpkgs.follows = "nixpkgs";
      nixpkgs-stable.follows = "stable";
    };

    stylix.url = "github:nix-community/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      debug = true;
      imports = [
        inputs.flake-parts.flakeModules.partitions
        ./home
        ./tests
        ./toplevel.nix
      ];
      partitionedAttrs = {
        checks = "dev";
        devShells = "dev";
        nixd = "dev";
        sites = "dev";
      };
      partitions.dev.extraInputsFlake = ./dev;
      systems = import inputs.systems;
    };
}
