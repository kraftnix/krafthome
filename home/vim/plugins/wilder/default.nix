# Fancy vim menus for ':', ':', '/', '?'
# allows fuzzy searching terms better
{pkgs, ...}: {
  plugins = [
    pkgs.vimPlugins.wilder-nvim
    pkgs.vimPlugins.cpsm
    pkgs.fd
  ];
  lua = builtins.readFile ./wilder.lua;
}
