{
  description = "Kraftnix's desktop nixos + home-manager modules";

  # Core
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.nixos.follows = "nixpkgs";
  inputs.stable.url = "github:nixos/nixpkgs/release-25.05";
  inputs.home.url = "github:nix-community/home-manager";
  inputs.home.inputs.nixpkgs.follows = "nixpkgs";

  inputs.kraftnvim.url = "github:kraftnix/kraftnvim";
  inputs.kraftnvim.inputs.nixpkgs.follows = "nixpkgs";

  inputs.provision.url = "github:kraftnix/provision-nix";
  inputs.provision.inputs = {
    nixpkgs.follows = "nixpkgs";
    nixpkgs-stable.follows = "stable";
  };
  inputs.extra-lib.follows = "provision/extra-lib";

  inputs.nur.url = "github:nix-community/NUR";

  ## Niri
  inputs.niri.url = "github:sodiboo/niri-flake";
  inputs.niri.inputs = {
    nixpkgs.follows = "nixpkgs";
    nixpkgs-stable.follows = "stable";
  };

  # Testing
  inputs = {
    stylix.url = "github:nix-community/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";

    elewrap.url = "github:oddlama/elewrap";
    elewrap.inputs.nixpkgs.follows = "nixpkgs";
  };

  # Dev
  inputs = {
    flake-parts.follows = "provision/flake-parts";
    git-hooks-nix.follows = "provision/git-hooks-nix";
    devshell.follows = "provision/devshell";
    colmena.follows = "provision/colmena";
    nvfetcher.url = "github:berberman/nvfetcher";
    nvfetcher.inputs = {
      nixpkgs.follows = "nixpkgs";
      flake-compat.follows = "provision/flake-compat";
      flake-utils.follows = "provision/flake-utils";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      debug = true;
      imports = [
        ./home
        ./tests
        ./toplevel.nix
      ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    };
}
