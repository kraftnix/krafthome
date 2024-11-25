# from nixpkgs
{lib, ...}: let
  inherit
    (lib)
    literalExpression
    mkOption
    types
    ;
in {
  options = {
    executable = mkOption {
      type = types.path;
      description = "Executable to run sandboxed";
      example = literalExpression ''"''${lib.getBin pkgs.firefox}/bin/firefox"'';
    };
    desktop = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ".desktop file to modify. Only necessary if it uses the absolute path to the executable.";
      example = literalExpression ''"''${pkgs.firefox}/share/applications/firefox.desktop"'';
    };
    profile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Profile to use";
      example = literalExpression ''"''${pkgs.firejail}/etc/firejail/firefox.profile"'';
    };
    extraArgs = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Extra arguments to pass to firejail";
      example = ["--private=~/.firejail_home"];
    };
  };
}
