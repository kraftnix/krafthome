{
  self,
  inputs,
  lib,
  ...
}:
let
  system = "x86_64-linux";
in
{
  flake.checks.${system} =
    (lib.genAttrs [
      "basic"
      "media"
      "dev-laptop"
    ] (name: self.nixosConfigurations.${name}.config.system.build.toplevel))
    // self.packagesGroups.${system}.nushellPlugins
  # // self.packagesGroups.${system}.vimPlugins
  # // self.packagesGroups.${system}.tree-sitter-grammars
  ;

  perSystem =
    {
      config,
      pkgs,
      ...
    }:
    let
      l = inputs.nixpkgs.lib;
      nixos-lib = import (inputs.nixpkgs + "/nixos/lib") { };
      makeTest =
        {
          host,
          test,
          specialArgs,
          ...
        }:
        nixos-lib.runTest {
          test = {
            hostPkgs = host.pkgs;
            node = {
              inherit specialArgs;
            };
          }
          // test;
          nodes.${host.config.networking.hostName} =
            {
              self,
              config,
              profiles,
              ...
            }:
            {
              imports = host._module.args.modules;
            };
        };
    in
    {
      # checks = {
      #   basic-test0 = nixos-lib.runTest {
      #     host = self.nixosConfigurations.basic;
      #     specialArgs = {
      #       inherit self;
      #       inherit (self) nixosModules profiles hmProfiles hmModules;
      #     };
      #     test = {
      #       name = "basic-test";
      #       testScript = ''
      #         host = "basic"
      #         start_all()
      #         host.wait_for_unit("default.target")
      #         host.wait_for_unit("multi-user.target")
      #       '';
      #     };
      #   };
      #   basic-test = nixos-lib.runTest {
      #     name = "basic-test";
      #     # imports = self.nixosConfigurations.basic._module.args.modules;
      #     hostPkgs = self.nixosConfigurations.basic.pkgs;
      #     node.specialArgs = {
      #       inherit self;
      #       inherit (self) nixosModules profiles hmProfiles hmModules;
      #     };
      #     nodes.basic = { config, profiles, ... }: {
      #       imports = self.nixosConfigurations.basic._module.args.modules;
      #     };
      #     testScript = ''
      #       host = "basic"
      #       start_all()
      #       host.wait_for_unit("default.target")
      #       host.wait_for_unit("multi-user.target")
      #     '';
      #   };
      #   basic-testOld = (makeTest {
      #     pkgs = self.nixosConfigurations.basic.pkgs;
      #     extraConfigurations = self.nixosConfigurations.basic._module.args.modules;
      #   } {
      #     name = "basic-test";
      #     nodes.test = { config, ... }: { };
      #     testScript = ''
      #       start_all()
      #       test.wait_for_unit("default.target")
      #       test.wait_for_unit("multi-user.target")
      #     '';
      #   }).test;
      #   media-test = (makeTest {
      #     pkgs = self.nixosConfigurations.basic.pkgs;
      #     extraConfigurations = self.nixosConfigurations.basic._module.args.modules;
      #   } {
      #     name = "media-test";
      #     nodes.test = { config, ... }: {
      #       imports = [ self.profiles.users.media ];
      #     };
      #     testScript = ''
      #       start_all()
      #       test.wait_for_unit("default.target")
      #       test.wait_for_unit("multi-user.target")
      #     '';
      #   }).test;
      # };
    };
}
