args:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    flatten
    literalExpression
    mkEnableOption
    mkOption
    pipe
    types
    ;
in
{
  options.home.firejail = {
    enable = mkEnableOption ''
      enable firejail integration.

      this module collects `wrappedBinaries` that the NixOS host needs
      to add to its `programs.firejail.wrappedBinaries`.
    '';
    # Copied from upstream
    wrappedBinaries = mkOption {
      type = types.attrsOf (
        types.submodule (
          { config, ... }:
          {
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
                default = [ ];
                description = "Extra arguments to pass to firejail";
                example = [ "--private=~/.firejail_home" ];
                apply =
                  args:
                  pipe config.whitelist [
                    (map (dir: [
                      "--whitelist"
                      dir
                    ]))
                    flatten
                    (whitelisted: whitelisted ++ args)
                  ];
              };

              # special options
              whitelist = mkOption {
                type = with types; listOf str;
                default = [ ];
                description = "Whitelist directories, adds `--whitelist <elem>` to `extraArgs`";
                example = [ "~/My_Documents" ];
              };
            };
          }
        )
      );
      default = { };
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
}
