{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    filter
    flatten
    flip
    literalExpression
    mapAttrs
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    pipe
    removeAttrs
    types
    ;
  cfg = config.home-manager.firejail;
in {
  options.home-manager.firejail = {
    enable = mkEnableOption ''
      enable firejail integration.

      this module collects `wrappedBinaries` from specified users
      home-manager configrations at `home.firejail.wrappedBinaries`
    '';
    users = mkOption {
      type = with types; listOf str;
      default = [];
      description = "home manager users to collect `home.firejail.wrappedBinaries` from";
    };
    # Copied from upstream
    wrappedBinaries = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          # default options
          executable = mkOption {
            type = types.path;
            description = "Executable to run sandboxed";
            example = literalExpression ''"''${lib.getBin pkgs.firefox}/bin/firefox"'';
          };
          desktop = mkOption {
            type = with types; nullOr path;
            default = null;
            description = ".desktop file to modify. Only necessary if it uses the absolute path to the executable.";
            example = literalExpression ''"''${pkgs.firefox}/share/applications/firefox.desktop"'';
          };
          profile = mkOption {
            type = with types; nullOr path;
            default = null;
            description = "Profile to use";
            example = literalExpression ''"''${pkgs.firejail}/etc/firejail/firefox.profile"'';
          };
          extraArgs = mkOption {
            type = with types; listOf str;
            default = [];
            description = "Extra arguments to pass to firejail";
            example = ["--private=~/.firejail_home"];
          };
        };
      });
      default = {};
      example = literalExpression ''
        {
          firefox = {
            executable = "''${lib.getBin pkgs.firefox}/bin/firefox";
            profile = "''${pkgs.firejail}/etc/firejail/firefox.profile";
          };
          mpv = {
            executable = "''${lib.getBin pkgs.mpv}/bin/mpv";
            profile = "''${pkgs.firejail}/etc/firejail/mpv.profile";
          };
        }
      '';
      description = ''
        Wrap the binaries in firejail and place them in the global path.
      '';
    };
  };
  config = mkIf cfg.enable {
    home-manager.firejail.wrappedBinaries = pipe cfg.users [
      (filter (user: config.home-manager.users.${user}.home.firejail.enable))
      (map (user: config.home-manager.users.${user}.home.firejail.wrappedBinaries))
      (map (mapAttrs (_: flip removeAttrs ["whitelist"])))
      mkMerge
    ];
    programs.firejail.wrappedBinaries = cfg.wrappedBinaries;
  };
}
