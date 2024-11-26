args:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    optionals
    ;
  cfg = config.khome.shell.ssh-rebind;
in
{
  options.khome.shell.ssh-rebind = {
    enable = mkEnableOption "enable ssh rebind";
  };

  config = mkIf cfg.enable {
    home.sessionVariables.SSH_AUTH_SOCK = "/home/${config.home.username}/.ssh/auth_sock";
    # home.packages = with cell.packages; [
    #   get-default-ssh
    #   get-recent-ssh
    #   skr
    #   skk
    # ];
  };
}
