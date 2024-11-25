{self, ...}: {
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  opts = self.inputs.extra-lib.lib.options;
  cfg = config.khome.desktop.apps.productivity.trilium;

  keybindings = {
    "$mod+n" = lib.mkOverride 500 "firefox -P home --new-window ${cfg.url}";
    "$mod+Shift+n" = lib.mkOverride 500 "move scratchpad, scratchpad show, ${cfg.swayResize}";
  };
in {
  options.khome.desktop.apps.productivity.trilium = {
    enable = opts.enable "enable trilium";
    sway = opts.enableTrue "enable sway integration (keybind)";
    swayResize = opts.string "resize set 1912 1043, move position 4 33" "extra resize + position commands for sway shortcut";
    url = opts.string "https://trilium.home.internal" "url of trilium instance to auto-open";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [trilium-desktop];
    wayland.windowManager.sway.config = mkIf cfg.sway {
      keybindings = keybindings;
    };
  };
}
