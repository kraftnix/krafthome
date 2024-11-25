args: {
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    mkOption
    mkOverride
    types
    ;
  cfg = config.khome.shell.aliases;
in {
  options.khome.shell.aliases = {
    enable = mkEnableOption "enable aliases";
    aliases = mkOption {
      default = {};
      description = "aliases for all home-manager users";
      type = types.attrsOf types.str;
    };
  };

  config = mkIf cfg.enable {
    home.shellAliases = builtins.mapAttrs (_: mkOverride 900) cfg.aliases;
    khome.shell.aliases.aliases = {
      # other
      fport = "ss -tlpn | grep";
      r = "ranger";
      zen = "zenith --db $XDG_DATA_HOME/zenith.db";

      skr = "export SSH_AUTH_SOCK=/run/user/$UID/gnupg/S.gpg-agent.ssh";
      skk = ''export SSH_AUTH_SOCK=$(nu -c "ls (ls /tmp/ | where name =~ "ssh-" | sort-by modified -r | get name | get 0) | get name.0")'';

      # X11
      disable_caps = "setxkbmap -option caps:escape";

      # yubikey
      otp = ''ykman oath code | fzf -q "$1" -m | awk '{split($0,a," "); print a[1]}' | xargs -ro ykman oath code | awk '{split($0,b," "); print b[2]}' | wl-copy'';

      # git
      wow = "git status";
      such = "git";
      doge = "git push";
      gc = "git checkout";
      gp = "git pull";
      gpp = "git push";
      gpu = "git pull upstream $(git branch --show-current)";
      gppu = "git push -u origin $(git branch --show-current)";

      # home-manager
      hms = "home-manager switch --flake .#$USER@$HOST switch";
      hmsb = "home-manager switch --flake .#$USER@$HOST switch -b";

      # mullvad connected
      mymull = "curl https://am.i.mullvad.net/connected";

      # sudo
      s = "sudo -E";
      se = "sudoedit";
      si = "sudo -i";
      stl = "doas systemctl";
      sudo = "doas";
      up = "doas systemctl start";
      down = "doas systemctl stop";
      status = "doas systemctl status";
      d = "doas";

      # lsd
      sls = "doas lsd";
      l = "lsd";
      ls = "lsd -lahFg";
      ll = "lsd -lFhg";
      la = "lsd -alFg";

      # rust alternatives
      cat-old = "/run/current-system/sw/bin/cat";
      cat = "bat";
      du-old = "/run/current-system/sw/bin/du";
      du = "dust";
      top-old = "/run/current-system/sw/bin/top";
      top = "btm";

      # tmux
      ta = "tmux new-session -A -s main";
      git-parent = "git log --pretty=format:'%D' HEAD^ | grep 'origin/' | head -n1 | sed 's@origin/@@' | sed 's@,.*@@'";

      # systemd
      ctl = "systemctl";
      ctls = "systemctl status";
      ctld = "systemctl down";
      ctlu = "systemctl up";
      # user systemd
      uctl = "systemctl --user";
      uctls = "systemctl --user status";
      uctld = "systemctl --user down";
      uctlu = "systemctl --user up";

      # journalctl
      j = "journalctl";
      jf = "journalctl -f";
      ju = "journalctl -u";
      jfu = "journalctl -f -u";
      # user journalctl
      uj = "journalctl --user";
      ujf = "journalctl --user -f";
      uju = "journalctl --user -u";
      ujfu = "journalctl --user -f -u";
    };
  };
}
