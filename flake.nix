{
  description = "Kraftnix's desktop nixos + home-manager modules";

  # Core
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.nixos.follows = "nixpkgs";
  inputs.stable.url = "github:nixos/nixpkgs/release-24.05";
  inputs.home.url = "github:nix-community/home-manager";
  inputs.home.inputs.nixpkgs.follows = "nixpkgs";
  inputs.wezterm.url = "github:wez/wezterm?dir=nix";

  inputs.extra-lib.url = "github:kraftnix/extra-lib";
  inputs.extra-lib.inputs.nixlib.follows = "nixpkgs";

  # Extra
  inputs = {
    haumea.url = "github:nix-community/haumea/v0.2.2";
    haumea.inputs.nixpkgs.follows = "nixpkgs";

    nur.url = "github:nix-community/NUR";

    # nix-index-database.url = "github:Mic92/nix-index-database";
    # nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    provision.url = "github:kraftnix/provision-nix";
    provision.inputs = {
      nixpkgs.follows = "nixpkgs";
      nixpkgs-stable.follows = "stable";
    };

    nvfetcher.url = "github:berberman/nvfetcher";
    nvfetcher.inputs = {
      nixpkgs.follows = "nixpkgs";
      flake-compat.follows = "provision/flake-compat";
      flake-utils.follows = "provision/flake-utils";
    };

    anyrun.url = "github:Kirottu/anyrun";
    anyrun.inputs.nixpkgs.follows = "nixpkgs";
    anyrun.inputs.flake-parts.follows = "flake-parts";

    stylix.url = "github:danth/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
    stylix.inputs.home-manager.follows = "home";

    elewrap.url = "github:oddlama/elewrap";
    elewrap.inputs.nixpkgs.follows = "nixpkgs";

    nix-fast-build.url = "github:Mic92/nix-fast-build";
    nix-fast-build.inputs = {
      flake-parts.follows = "provision/flake-parts";
      nixpkgs.follows = "nixpkgs";
    };
  };

  # follows
  inputs = {
    flake-parts.follows = "provision/flake-parts";
    git-hooks-nix.follows = "provision/git-hooks-nix";
    devshell.follows = "provision/devshell";
    colmena.follows = "provision/colmena";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
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

  nixConfig = {
    extra-experimental-features = "nix-command flakes";
    extra-substituters = "https://nix-community.cachix.org";
    extra-trusted-public-keys = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
  };
}
