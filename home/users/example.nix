{ pkgs, ... }:
{
  khome.shell = {
    direnv.enable = true;
    core-tools.enable = true;
    misc.enable = true;
    ssh-rebind.enable = true;
    zsh.enable = true;
    fzf.enable = true;
    git.enable = true;
    xplr.enable = true;
    nix-tools.enable = true;
    nix-index.enable = true;
    nix-index.enableComma = true;
    yazi = {
      enable = true;
      theme = {
        name = "tokyo-night";
        src = pkgs.fetchFromGitHub {
          owner = "BennyOe";
          repo = "tokyo-night.yazi";
          rev = "024fb096821e7d2f9d09a338f088918d8cfadf34";
          hash = "sha256-IhCwP5v0qbuanjfMRbk/Uatu31rPNVChJn5Y9c5KWYQ=";
        };
      };
      plugins.bookmarks.enable = true;
    };
  };
  khome.nushell = {
    enable = true;
    enableStarship = true;
    enableAtuin = true;
    plugins = [
      pkgs.nushellPlugins.polars
      pkgs.nushellPlugins.net
      pkgs.nushellPlugins.query
      pkgs.nushellPlugins.gstat
      pkgs.nushellPlugins.formats

      # requires nushellPlugins overlay
      pkgs.nushellPlugins.explore
      pkgs.nushellPlugins.dbus
      pkgs.nushellPlugins.port_list
      pkgs.nushellPlugins.prometheus # 0.97 not supported yet
      # pkgs.nushellPlugins.dialog
      pkgs.nushellPlugins.skim
    ];
    shellAliases = { };
    extraConfig = ''
      def ssh-fpscan [] {
        ssh-keyscan localhost | ssh-keygen -lf -
      }

      # Point ~/.ssh/auth_sock to most recently created SSH_AUTH_SOCK in /tmp/
      def skre [] {
        let auth_socks = (ls /tmp/ | where name =~ "ssh-")
        if $auth_socks == [] {
          print $"(ansi red)No auth sockets found(ansi reset) in (ansi yellow)/tmp/ssh-*(ansi reset)"
          exit 1
        } else {
          let auth_sock_dir = ($auth_socks | sort-by modified -r | get name | get 0)
          let auth_sock = (ls $auth_sock_dir | get 0.name)
          ln -sf $auth_sock ~/.ssh/auth_sock
          print $"(ansi green)Set auth sock to:(ansi reset) (ansi yellow)($auth_sock)(ansi reset)"
        }
      }
    '';
  };
  home.stateVersion = "23.11";
}
