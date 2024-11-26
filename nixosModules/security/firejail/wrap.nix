{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    getBin
    mapAttrs
    mkIf
    ;
  mkFirejail =
    name:
    {
      executableName ? name,
      packageName ? executableName,
      executable ? "${getBin pkgs.${packageName}}/bin/${executableName}",
      profile ? "${pkgs.firejail}/etc/firejail/${executableName}.profile",
      desktop ? "",
      extraArgs ? [ ],
      ...
    }:
    {
      inherit executable profile extraArgs;
      desktop = mkIf (desktop != "") desktop;
    };
in
{
  programs.firejail.enable = true;
  programs.firejail.wrappedBinaries = mapAttrs mkFirejail {
    tshark = { };
    mpv = { };
    wireshark = { };
    zathura = { };
  };
}
