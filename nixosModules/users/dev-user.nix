{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.khome.users.dev-user;
  inherit (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    mkOverride
    optional
    types
    ;
  userHm = config.home-manager.users.${cfg.name};
in
{
  options.khome.users.dev-user = {
    enable = mkEnableOption "enable dev user";
    name = mkOption {
      type = types.str;
      default = "dev-user";
      description = "username to provision";
    };
    shell = mkOption {
      default =
        if userHm.khome.nushell.enable then
          userHm.khome.nushell.package
        else if userHm.khome.shell.zsh.enable then
          pkgs.zsh
        else
          pkgs.bash;
      type = types.package;
      description = "default user shell";
    };
    addToWheel = mkEnableOption "add to wheel group";
    uid = mkOption {
      type = types.int;
      default = 1000;
      description = "media user uid";
    };
    extraGroups = mkOption {
      description = "extra groups to add user to";
      default = [ ];
      type = with types; listOf str;
    };
    keyFiles = mkOption {
      description = "pubkey files to add to openssh authorized";
      default = [ ];
      type = with types; listOf path;
    };
    hashedPassword = mkOption {
      type = types.str;
      default = "$6$UpKEXaKM$WRg6Hsf6BkaAX6iF3/ODJBW1fG.PCDxTXlnvTCLQlIfmczjuACmjm4T2rPWvpPA.RxG2.0ClkA1zaFtKCX13x.";
      description = "default media password";
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.${cfg.name} =
      { pkgs, ... }:
      {
        imports = [ ../../home/profiles/themes/tokyo-night ];
        khome.roles.basic.enable = true;
        khome.roles.dev.enable = true;
        provision.scripts.enable = true;
        provision.scripts.scripts = {
          am-i-dev-user.inputs = [ pkgs.afetch ];
          am-i-dev-user.text = ''
            # test function
            def main [ ] {
              ^afetch
            }
          '';
        };
        home.stateVersion = lib.mkOptionDefault "22.05";
      };
    # System user config
    users.users.${cfg.name} = {
      hashedPassword = mkOverride 200 cfg.hashedPassword;
      uid = mkOverride 200 cfg.uid;
      shell = mkOverride 200 cfg.shell;
      isNormalUser = true;
      extraGroups = [ "tty" ] ++ (optional cfg.addToWheel "wheel") ++ cfg.extraGroups;
      openssh.authorizedKeys.keyFiles = cfg.keyFiles;
    };
  };
}
