# press `s` to hop/jump to a selection (like vimium)
{ pkgs, ... }:
{
  plugins = with pkgs.vimPlugins; [
    nvim-telescope-hop
  ];
  lua = builtins.readFile ./hop.lua;
}
