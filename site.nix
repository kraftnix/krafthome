localFlake:
let
  lib = localFlake.lib;
  krafthome-local = {
    mdbook.src = ./.;
    homepage = {
      url = "http://localhost:8937";
      body = "Homepage";
    };
    docgen.flake-all = {
      hostOptions =
        (localFlake.flake-parts-lib.evalFlakeModule { inputs.self = localFlake.self; } {
          imports = [
            # localFlake.self.auto-import.flake.modules.vim-plugins
            ./flakeModules/vim-plugins.nix
          ];
          systems = [
            (throw "The `systems` option value is not available when generating documentation. This is generally caused by a missing `defaultText` on one or more options in the trace. Please run this evaluation with `--show-trace`, look for `while evaluating the default value of option` and add a `defaultText` to the one or more of the options involved.")
          ];
        }).options;
      filter =
        option:
        let
          flakeEnabled = (builtins.elemAt option.loc 0 == "flake" && builtins.length option.loc > 1);
          perSystemEnabled = (builtins.elemAt option.loc 0 == "perSystem" && builtins.length option.loc > 1);
          loc1 = name: builtins.elemAt option.loc 1 == name;
        in
        # (flakeEnabled
        #   && (
        #     (loc1 "docs")
        #     || (loc1 "hosts")
        #   ))
        # ||
        (
          perSystemEnabled
          && (
            (loc1 "vimPlugins")
            # || (loc1 "sites")
          )
        );
    };
    docgen.nixos-all.filter = option: builtins.elemAt option.loc 0 == "khome";
    docgen.home-all.hostOptions =
      # (lib.evalModules {
      #   specialArgs = { inherit lib; };
      #   modules = [
      #     # {options.home.packages = lib.mkOption {default = {};};}
      #   ] ++ (localFlake.self.nixosConfigurations.dev-laptop.config.home-manager.sharedModules);
      # })
      # .options;
      (localFlake.inputs.home.lib.homeManagerConfiguration {
        pkgs = localFlake.self.nixosConfigurations.dev-laptop.pkgs;
        inherit (localFlake.self.nixosConfigurations.dev-laptop.config.home-manager) extraSpecialArgs;
        modules =
          localFlake.self.auto-import.homeManager.all
          ++ localFlake.self.externalHomeModules
          ++ [
            localFlake.inputs.provision.homeManagerModules.provision-scripts
            # localFlake.inputs.nix-index-database.hmModules.nix-index
            localFlake.inputs.stylix.homeModules.stylix
            (
              { config, ... }:
              {
                options.meta.doc = lib.mkOption { default = { }; };
                config.home.stateVersion = "23.11";
                config.home.username = "devuser";
                config.home.homeDirectory = "/home/devuser";
                config.stylix.image = ./home/modules/themes/wallpaper.jpg;
              }
            )
          ];
      }).options;

    docgen.home-all.filter = option: builtins.elemAt option.loc 0 == "khome";
  };
in
{
  flake.docs = {
    enable = true;
    defaults = {
      nuscht-search.baseHref = "/search/";
      nuscht-search.title = "Kraftnix Options Search";
      nuscht-search.customTheme = ./docs/theme/css/nuscht-search.css;
      hostOptions = localFlake.self.nixosConfigurations.dev-laptop.options;
      substitution.outPath = localFlake.self.outPath;
      # substitution.gitRepoFilePath = "https://github.com/kraftnix/krafthome";
      substitution.gitRepoUrl = "https://gitea.home.lan/kraftnix/krafthome";
      # substitution.gitRepoFilePath = "https://github.com/kraftnix/krafthome/tree/master/";
      substitution.gitRepoFilePath = "https://gitea.home.lan/kraftnix/krafthome/src/branch/master/";
    };
    sites = {
      inherit krafthome-local;
      krafthome = lib.mkMerge [
        krafthome-local
        {
          homepage = lib.mkForce {
            url = "https://kraftnix.dev";
            body = "Homepage";
            siteBase = "/projects/krafthome/";
          };
          defaults.substitution.gitRepoUrl = lib.mkForce "https://github.com/kraftnix/krafthome";
          defaults.substitution.gitRepoFilePath = lib.mkForce "https://github.com/kraftnix/krafthome/tree/master";
        }
      ];
    };
  };
}
