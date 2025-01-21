{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib)
    getBin
    mkDefault
    mkForce
    mkEnableOption
    mkOption
    types
    ;
in
{
  options = {
    enable = mkEnableOption "enable wrapper" // {
      default = true;
    };
    name = mkOption {
      default = config._module.args.name;
      description = "wrapper name";
      type = types.str;
    };
    package = mkOption {
      default = pkgs.${config.packageName};
      description = "package to wrap";
      type = types.package;
    };
    executable = mkOption {
      default = config.name;
      description = "executable name, use as `/bin/` match";
      type = types.str;
    };
    executablePath = mkOption {
      default = "${getBin pkgs.${config.packageName}}/bin/${config.executable}";
      description = "full path to executable";
      type = types.str;
    };
    packageName = mkOption {
      default = config.executable;
      description = "package name, used to match `$\{pkgs.$\{executable}}`";
      type = types.str;
    };
    firejail = mkOption {
      default = { };
      description = "enable firejail integration";
      type = types.submoduleWith {
        modules = [
          ./firejail/binary-wrapper.nix
          ./firejail/binary-extensions.nix
          {
            config._module.args.pkgs = pkgs;
            config._module.args.name = mkForce config.name;
            config.enable = mkDefault false;
            config.executable = mkDefault config.executablePath;
            config.profile = mkDefault "${pkgs.firejail}/etc/firejail/${config.executable}.profile";
          }
        ];
      };
    };
    elewrap = mkOption {
      default = { };
      description = "elewrap wrapper script";
      type = types.submoduleWith {
        modules = [
          ./elewrap/elewrap-element.nix
          (elewrap: {
            config._module.args.name = mkForce config.name;
            options.enable = mkEnableOption "enable elewrap wrapper";
            options.extraCommandArgs = mkOption {
              default = [ ];
              type = with types; listOf str;
              description = "extra args to add to default command";
            };
            config.targetUser = mkDefault "root";
            config.command = mkDefault (
              [
                (
                  # TODO: test if firejail + elewrap work together
                  if config.firejail.enable then
                    "${config.firejail.binary}/bin/${config.executable}"
                  else
                    config.executablePath
                )
              ]
              ++ elewrap.config.extraCommandArgs
            );
          })
        ];
      };
    };
  };
}
