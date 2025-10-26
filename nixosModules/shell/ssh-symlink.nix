{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.khome.shell.ssh-symlink;
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in
{
  options.khome.shell.ssh-symlink = {
    enable = mkEnableOption "enable ssh symlink integration";
    packages = mkOption {
      description = "packages to add to {environment.systemPackages}";
      default = { };
      type = with types; attrsOf package;
    };
  };

  config = mkIf cfg.enable {
    khome.shell.ssh-symlink.packages = {
      ske = pkgs.writeScriptBin "ske" ''
        export SSH_AUTH_SOCK=~/.ssh/auth_sock
      '';
      skl = pkgs.writeScriptBin "skl" ''
        readlink -f $SSH_AUTH_SOCK
      '';
      skre = pkgs.writeScriptBin "skre" ''
        ln -sf /run/user/$UID/gnupg/S.gpg-agent.ssh /home/$USER/.ssh/auth_sock
      '';
      # for ssh 10.1+
      skke = pkgs.writeScriptBin "skke" ''
        ln -sf $(nu -c "ls (ls /home/$USER/.ssh/agent/ | where name =~ "sshd" | sort-by modified -r | get name | get 0) | get name.0") /home/$USER/.ssh/auth_sock
      '';
      # for ssh <10.1
      skke-old = pkgs.writeScriptBin "skke" ''
        ln -sf $(nu -c "ls (ls /tmp/ | where name =~ "ssh-" | sort-by modified -r | get name | get 0) | get name.0") /home/$USER/.ssh/auth_sock
      '';
      skkg = pkgs.writeScriptBin "skkg" ''
        export SSH_AUTH_SOCK="$(${pkgs.gnupg}/bin/gpgconf --list-dirs agent-ssh-socket)
      '';
    };
    environment.systemPackages = builtins.attrValues cfg.packages;
    # environment.shellAliases = {
    #   ske = "export SSH_AUTH_SOCK=~/.ssh/auth_sock";
    #   skre = "ln -sf /run/user/$UID/gnupg/S.gpg-agent.ssh /home/$USER/.ssh/auth_sock";
    #   #skre = "sh -c \"ln -sf ~/.ssh/auth_sock `readlink -f /run/user/1000/gnupg/S.gpg-agent.ssh`; chmod 0600 ~/.ssh/auth_sock\"";
    #   #skre = "sh -c \"ln -sf $(readlink -f /run/user/1000/gnupg/S.gpg-agent.ssh) ~/.ssh/auth_sock; chmod 0600 ~/.ssh/auth_sock\"";
    #   skke = ''ln -sf $(nu -c "ls (ls /tmp/ | where name =~ "ssh-" | sort-by modified -r | get name | get 0) | get name.0") /home/$USER/.ssh/auth_sock'';
    #   skkg = "export SSH_AUTH_SOCK=\"$(${pkgs.gnupg}/bin/gpgconf --list-dirs agent-ssh-socket)\"";
    # };
  };
}
