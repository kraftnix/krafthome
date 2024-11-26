{ self, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    mkMerge
    genAttrs
    mapAttrs'
    nameValuePair
    ;
  opts = self.inputs.extra-lib.lib.options;
  cfg = config.khome.desktop.apps.productivity.joplin;

  pluginDir = "joplin-desktop/plugins";
  plugins = pkgs.fetchFromGitHub {
    owner = "joplin";
    repo = "plugins";
    rev = "62ad814c154b872467c1409b21df8a8ab603349c";
    sha256 = "sha256-C2/XulPYDkFU9U0/OwM8SmhLvZj3laalAoxpxoLbWvw=";
  };
  mkPluginLink = name: {
    source = "${plugins}/plugins/${name}/plugin.jpl";
  };
  pluginList = [
    "ambrt.backlinksToNote"
    "com.whatever.quick-links"
    "io.treymo.LinkGraph"
  ];
  pluginAttrs = genAttrs pluginList (name: mkPluginLink name);
  homeLinks = mapAttrs' (name: value: nameValuePair "${pluginDir}/${name}.jpl" value) pluginAttrs;
in
{
  options.khome.desktop.apps.productivity.joplin = {
    enable = opts.enable "enable joplin";
    sway = opts.enableTrue "enable sway (and i3) integration (command + keybind)";
    cli = opts.enableTrue "enable cli";
    desktop = opts.enableTrue "enable desktop";
  };

  config = mkMerge [
    ## CLI
    (mkIf (cfg.enable && cfg.cli) {
      home.packages = with pkgs; [
        joplin
        (makeDesktopItem {
          name = "joplin";
          desktopName = "Joplin";
          # TODO: couple less to alacritty
          exec = "${pkgs.alacritty}/bin/alacritty --class=joplin -e ${pkgs.joplin}/bin/joplin";
          icon = "joplin";
          genericName = "Notes App (CLI)";
          categories = "Office";
        })
      ];
      wayland.windowManager.sway.config = {
        window.commands = [
          {
            command = "move scratchpad, scratchpad show, resize set 1400 950";
            criteria = {
              app_id = "joplin";
            };
          }
        ];
      };
      xsession.windowManager.i3.config = {
        window.commands = [
          {
            command = "move scratchpad, scratchpad show, resize set 1400 950";
            criteria = {
              app_id = "joplin";
            };
          }
        ];
      };

      xdg.configFile."joplin/keymap.json".source = ./keymap.json;
    })

    ## Desktop
    (mkIf (cfg.enable && cfg.desktop) {
      home.packages = with pkgs; [
        joplin-desktop
      ];
      xdg.configFile = homeLinks;
    })
  ];
}
