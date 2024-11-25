{
  config,
  pkgs,
  ...
}: let
  local = import ../themes.nix;
  base16 = config.lib.base16;
  colors = with base16.theme; {
    primary = magenta;
    secondary = cyan;
  };
in {
  khome.themes = with base16.theme; {
    enable = true;
    # base16 = {
    #   colors = colors;
    #   localTheme = local.tokyo-night4;
    #   programs = {
    #     mako.extraParams = with colors; {
    #       background = red;
    #     };
    #     alacritty.extraParams = {
    #       base05 = cyan;
    #     };
    #     vim = {
    #       #extraParams.base02 = base01;
    #     };
    #     vim-airline-themes = {
    #       extraParams.base01 = foreground;
    #       extraParams.base02 = foreground;
    #       extraParams.base03 = foreground;
    #       extraParams.base04 = foreground;
    #     };
    #     rofi.extraParams = {
    #       base01 = base07;
    #       base02 = red;
    #       base03 = red;
    #       base04 = red;
    #       base05 = magenta;
    #       base06 = cyan;
    #       base07 = red;
    #       base08 = red;
    #       base09 = red;
    #       base0A = red;
    #       base0B = red;
    #       base0C = red;
    #       base0D = red;
    #       base0E = red;
    #       base0F = red;
    #     };
    #     waybar.extraParams = {
    #       workspace = red;
    #       workspaceBorder = red;
    #       mode = magenta;
    #       clock = foreground;
    #       audio = green;
    #       network = orange;
    #       cpu = foreground;
    #       temperature = red;
    #       memory = cyan;
    #       disk = magenta;
    #       battery = blue;
    #     };
    #   };
    # };
    # gtk = {
    #   theme = {
    #     name = "Sweet-Dark";
    #     package = pkgs.sweet;
    #   };
    #   iconTheme = {
    #     name = "Papirus-Dark";
    #     package = pkgs.papirus-icon-theme;
    #   };
    # };
    # extra = {
    #   screensaverPath = "~/pictures/wallpapers/screensaver.jpg";
    #   # require systemd $h home directory arg
    #   wallpaperDir = "%h/pictures/remote/Wallpapers";
    #   opacity = 0.95;
    # };
  };
}
