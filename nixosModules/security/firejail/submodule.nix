# Taken from nixpkgs and turned into a submodule
{
  config,
  lib,
  pkgs,
  descriptions,
  ...
}:
let
  inherit (lib)
    concatStringsSep
    filterAttrs
    literalExpression
    mapAttrs
    mapAttrsToList
    mkEnableOption
    mkOption
    pipe
    types
    ;
  cfg = config;

  finalDescriptions = {
    enable = "firejail, a sandboxing tool for Linux";
  }
  // descriptions;

  wrappedBinContents =
    command: value:
    let
      opts =
        if builtins.isAttrs value then
          value
        else
          {
            executable = value;
            desktop = null;
            profile = null;
            extraArgs = [ ];
          };
      args = lib.escapeShellArgs (
        opts.extraArgs
        ++ (lib.optional (opts.profile != null) "--profile=${builtins.toString opts.profile}")
      );
    in
    ''
      cat <<_EOF >$out/bin/${command}
      #! ${pkgs.runtimeShell} -e
      exec /run/wrappers/bin/firejail ${args} -- ${builtins.toString opts.executable} "\$@"
      _EOF
      chmod 0755 $out/bin/${command}

      ${lib.optionalString (opts.desktop != null) ''
        substitute ${opts.desktop} $out/share/applications/$(basename ${opts.desktop}) \
          --replace ${opts.executable} $out/bin/${command}
      ''}
    '';
  wrappedBin =
    command: value:
    pkgs.runCommand "firejail-wrapped-${command}"
      {
        preferLocalBuild = true;
        allowSubstitutes = false;
        # take precedence over non-firejailed versions
        meta.priority = -3; # more priority to individual wrappedBin
      }
      ''
        mkdir -p $out/bin
        mkdir -p $out/share/applications
        ${wrappedBinContents command value}
      '';

  wrappedBins =
    pkgs.runCommand "firejail-wrapped-all-binaries"
      {
        preferLocalBuild = true;
        allowSubstitutes = false;
        # take precedence over non-firejailed versions
        meta.priority = -2;
      }
      ''
        mkdir -p $out/bin
        mkdir -p $out/share/applications
        ${concatStringsSep "\n" (
          mapAttrsToList wrappedBinContents (filterAttrs (_: b: b.enable) cfg.wrappedBinaries)
        )}
      '';
in
{
  options = {
    enable = mkEnableOption finalDescriptions.enable;

    allBinaries = mkOption {
      default = wrappedBins;
      type = types.package;
      description = "wrappedBinaries generated package";
    };

    binaries = mkOption {
      default = pipe cfg.wrappedBinaries [
        (filterAttrs (_: b: b.enable))
        (mapAttrs wrappedBin)
      ];
      type = with types; attrsOf package;
      description = "wrappedBinaries generated package";
    };

    wrappedBinaries = mkOption {
      type = types.attrsOf (
        types.either types.path (
          types.submoduleWith {
            modules = [
              ./binary-extensions.nix
              ./binary-wrapper.nix
              { config._module.args.pkgs = pkgs; }
            ];
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
