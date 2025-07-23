{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    flatten
    map
    mapAttrs
    mapAttrsToList
    mkEnableOption
    mkOption
    optional
    types
    ;
  mkListOption =
    name: opts:
    mkOption (
      {
        type = with types; listOf str;
        default = [ ];
        description = "${name}, adds `--${name}=<elem>` to `extraArgs`";
      }
      // opts
    );
  options = {
    whitelist.example = [ "~/My_Documents" ];
    protocol.example = [ "netlink,unix" ];
    ignore.example = [ "private-dev" ];
    blacklist.example = [ "/dev" ];
  };
  wrappedBinContents =
    command: value:
    let
      opts = value;
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
in
{
  options = {
    enable = mkEnableOption "enable binary wrapper" // {
      default = true;
    };
    enableNotifications = mkEnableOption ''
      Enables access to dbus for notifications, via:
      `dbus-user.talk org.freedesktop.Notifications`
    '';
    binary = mkOption {
      default = wrappedBin config._module.args.name config;
      description = "firejail-wrapped binary";
      type = types.package;
    };
  }
  // (mapAttrs mkListOption options);
  config.extraArgs = flatten [
    (mapAttrsToList (opt: _: map (v: "--${opt}=${v}") config.${opt}) options)
    (optional config.enableNotifications "--dbus-user.talk=org.freedesktop.Notifications")
  ];
}
