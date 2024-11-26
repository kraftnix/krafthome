{
  self,
  lib,
  withSystem,
  ...
}:
{
  flake.lib = rec {
    provision = self.inputs.provision.lib;
    # NOTE(URGENT): THESE NEED BACKPORTING TO KRAFTHOME
    khome.toggleApp = cmd: "exec nu ${../../home/modules/desktop/wm/sway/sway-toggle-app.nu} ${cmd}";
    khome.wrapSwayrLog = cmd: "exec env RUST_BACKTRACE=1 swayr ${cmd} >> /tmp/swayr.log 2>&1";

    kebabCaseToCamelCase = builtins.replaceStrings (map (s: "-${s}") lib.lowerChars) lib.upperChars;

    # from https://sourcegraph.com/github.com/terlar/nix-config/-/blob/flake-parts/lib/default.nix
    importDirToAttrsList =
      dir:
      lib.pipe dir [
        lib.filesystem.listFilesRecursive
        (builtins.filter (lib.hasSuffix ".nix"))
        (map (path: {
          name = lib.pipe path [
            toString
            (lib.removePrefix "${toString dir}/")
            (lib.removeSuffix "/default.nix")
            (lib.removeSuffix ".nix")
            self.lib.kebabCaseToCamelCase
            (builtins.replaceStrings [ "/" ] [ "-" ])
          ];
          value = import path;
        }))
        builtins.listToAttrs
      ];

    filteredDirList =
      dir:
      lib.pipe dir [
        lib.filesystem.listFilesRecursive
        (builtins.filter (lib.hasSuffix ".nix"))
        (map (path: {
          inherit path;
          name = lib.pipe path [
            toString
            (lib.removePrefix "${toString dir}/")
            (lib.removeSuffix "/default.nix")
            (lib.removeSuffix ".nix")
            self.lib.kebabCaseToCamelCase
            (builtins.replaceStrings [ "/" ] [ "-" ])
          ];
        }))
      ];

    nameToAttrs =
      {
        name,
        path,
      }:
      lib.setAttrByPath (lib.splitString [ "-" ] name) path;

    importDirToAttrs' =
      files:
      lib.pipe files [
        (map nameToAttrs)
        (lib.foldAttrs (item: acc: lib.recursiveUpdate acc item) { })
      ];

    # returns an attrSet of all paths imported
    # directory structure is maintained as attrSets
    # Path -> { Path = import Path; }
    # e.g. importDirToAttrs ./lib
    #   ->  { network = { core = import ./lib/network/core.nix; }; basic = import ./lib/basic.nix; }
    importDirToAttrs =
      dir:
      lib.pipe dir [
        filteredDirList
        importDirToAttrs'
      ];

    # create system with special imported args
    kNixos =
      system: importedConfig:
      withSystem system (
        {
          pkgs,
          self',
          inputs',
          ...
        }:
        pkgs.nixos (
          {
            config,
            lib,
            packages,
            pkgs,
            ...
          }:
          {
            imports = [ importedConfig ];
            _module.args = {
              inherit (self)
                nixosModules
                profiles
                hmProfiles
                homeModules
                ;
            };
          }
        )
      );

    # WIP: attempt to pass in specialArgs in a wrapper
    kNixos1 =
      system: importedConfig:
      withSystem system (
        {
          pkgs,
          self',
          inputs',
          ...
        }:
        let
          specialArgs = {
            inherit (self)
              nixosModules
              profiles
              hmProfiles
              homeModules
              ;
          };
        in
        lib.evalModules {
          inherit specialArgs;
          modules = [
            importedConfig
            (
              { config, ... }:
              {
                _module.args = specialArgs;
              }
            )
          ];
        }
      );
  };
}
