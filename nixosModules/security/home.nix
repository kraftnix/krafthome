localFlake:
{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib)
    mapAttrsToList
    filterAttrs
    flatten
    mkIf
    mkEnableOption
    mkOption
    pipe
    types
    ;
  cfg = config.provision.security;
  enabledWrappers = filterAttrs (_: w: w.enable) cfg.wrappers;
in
{
  options.provision.security = {
    addWrappers = mkEnableOption "add firejail wrapped binaries to `home.packages`";
    wrappers = mkOption {
      default = { };
      description = ''
        Security wrappers which use `firejail` and/or `elewrap` to generate
        executable sandboxed wrappers.
          - firejail provides sandboxing
          - elewrap provides setuid, checksum verification, acl per user/group
      '';
      type = types.attrsOf (
        types.submoduleWith {
          modules = [
            ./wrapper.nix
            { config._module.args.pkgs = pkgs; }
          ];
        }
      );
    };
  };

  config = mkIf cfg.addWrappers {
    home.packages = pipe enabledWrappers [
      (filterAttrs (_: w: w.firejail.enable))
      (mapAttrsToList (_: w: w.firejail.binary))
      flatten
    ];
  };
}
