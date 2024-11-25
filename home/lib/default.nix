{
  self,
  inputs,
  ...
}: let
  inherit (inputs.nixpkgs) lib;
in {
  createPipedDesktop = name: {
    vmName,
    sshOpts,
    pkgs,
    menuName ? "${vmName}: ${name}",
    genericName ? name,
    icon ? name,
    categories ? [],
    mimeType ? [],
    instanceNumber ? 0,
    executable ? name,
    settings ? {},
    script ? (
      let
        sockName = "${builtins.replaceStrings [">"] ["_"] name}${toString instanceNumber}";
      in
        pkgs.writeShellScript "waypipe-${vmName}-${name}${toString instanceNumber}" ''
          env
          BASEDIR=/tmp/waypipe-${vmName}
          HOSTSOCK=$BASEDIR/host-${sockName}
          GUESTSOCK=/tmp/waypipe-${sockName}
          ${pkgs.coreutils}/bin/mkdir -p $BASEDIR
          rm -rf $HOSTSOCK
          ${pkgs.waypipe}/bin/waypipe --socket $HOSTSOCK client  &
          env DISPLAY=:0 WAYLAND_DISPLAY=wayland-1 SSH_AUTH_SOCK=/run/user/$UID/gnupg/S.gpg-agent.ssh \
            ${pkgs.openssh}/bin/ssh -R $GUESTSOCK:$HOSTSOCK ${sshOpts} \
              waypipe --socket $GUESTSOCK server -- ${executable} &> $BASEDIR/${sockName}-log.txt &
        ''
    ),
    ...
  }: {
    inherit icon genericName categories mimeType settings;
    name = menuName;
    exec = "${script}";
    #terminal = true;
  };
}
