{
  config,
  options,
  pkgs,
  lib,
  ...
}: let
  inherit
    (lib)
    filterAttrs
    flatten
    getAttrByPath
    hasAttrByPath
    mapAttrs
    mapAttrs'
    mapAttrsToList
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    nameValuePair
    optionalAttrs
    pipe
    types
    ;
  cfg = config.provision.security;
  enabledWrappers = filterAttrs (_: w: w.enable) cfg.wrappers;
  filterElewrap = wrappers:
    pipe wrappers [
      (filterAttrs (_: w: w.enable))
      (filterAttrs (_: w: w.elewrap.enable))
      (mapAttrs' (_: w:
        nameValuePair w.name (removeAttrs w.elewrap [
          "enable"
          "extraCommandArgs"
          "path"
        ])))
    ];
  hmWrappers = pipe config.home-manager.users [
    (filterAttrs (_: hasAttrByPath ["provision"]))
    (filterAttrs (_: hasAttrByPath ["provision" "secrets"]))
    (mapAttrs (_: getAttrByPath ["provision" "secrets" "wrappers"]))
    filterElewrap
  ];
in {
  options.provision.security = {
    enable = mkEnableOption "enable provision security";
    addWrappers =
      mkEnableOption "add firejail wrapped binaries to `environment.systemPackages`"
      // {
        default = cfg.enable;
      };
    collectHomeManager =
      mkEnableOption "collects elewrap binaries from `home-manager.users.<user>.provision.secrets.wrappers`"
      // {
        default = cfg.enable;
      };
    wrappers = mkOption {
      default = {};
      description = ''
        Security wrappers which use `firejail` and/or `elewrap` to generate
        executable sandboxed wrappers.
          - firejail provides sandboxing
          - elewrap provides setuid, checksum verification, acl per user/group
      '';
      type = types.attrsOf (types.submoduleWith {
        modules = [
          ./wrapper.nix
          {config._module.args.pkgs = pkgs;}
        ];
      });
    };
  };

  config =
    {
      programs.firejail.enable = mkDefault (enabledWrappers != {});
      environment.systemPackages = mkIf cfg.addWrappers (pipe enabledWrappers [
        (filterAttrs (_: w: w.firejail.enable))
        (mapAttrsToList (_: w: w.firejail.binary))
        flatten
      ]);
    }
    // (optionalAttrs (options.security ? elewrap) {
      security.elewrap = filterElewrap enabledWrappers // (optionalAttrs cfg.collectHomeManager hmWrappers);
    });
}
