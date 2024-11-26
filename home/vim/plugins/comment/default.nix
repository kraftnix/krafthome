# Project management with telescope
# - auto searchs in homedir for git repos
# - move between projects (change working dir)
# - search inside projects
{ pkgs, ... }:
{
  plugins = with pkgs.vimPlugins; [
    comment-nvim # easily comment lines
  ];
  lua = ''
    require('Comment').setup()
  '';
}
