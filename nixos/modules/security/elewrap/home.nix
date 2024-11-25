localFlake: {
  config,
  pkgs,
  lib,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  cfg = config.home.elewrap;
in {
  options.home.elewrap = {
    enable = mkEnableOption "enable elewrap wrapper";
    wrappers = mkOption {
      default = {};
      description = ''
        Collects binaries to pass onto host level `security.elewrap`.

        Transparently wraps programs to allow controlled elevation of privileges.
        Like sudo, doas or please but the authentication rules are kept simple and will
        be baked into the wrapper at compile-time, cutting down any attack surface
        to the absolute bare minimum.
      '';
      type = types.attrsOf (types.submoduleWith {
        modules = [./elewrap-element.nix];
      });
    };
  };
}
