{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    genAttrs
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  cfg = config.khome.roles.dev;
  secEnable = cfg.security.enable;
  defaultSec = mkDefault secEnable;
in
{
  options.khome.roles.dev = {
    enable = mkEnableOption ''
      Enables developer role.
    '';
    graphical = mkEnableOption ''
      Enables graphical options.
    '';
    users = mkOption {
      default = [ ];
      description = "user to passthrough `khome.roles.dev` home-manager options for";
      type = with types; listOf str;
    };
    security.enable = mkEnableOption "enable `provision.security.wrappers`";
  };

  config = mkIf cfg.enable {
    provision.security.enable = defaultSec;
    provision.security.addWrappers = defaultSec;
    provision.security.collectHomeManager = defaultSec;
    home-manager.users = genAttrs cfg.users (
      user:
      (
        { config, ... }:
        {
          home.firejail.enable = defaultSec;
          home.firejail.addToHomePackages = defaultSec;
          provision.security.addWrappers = defaultSec;
          khome.roles.dev = {
            inherit (cfg) enable graphical;
          };
        }
      )
    );
  };
}
