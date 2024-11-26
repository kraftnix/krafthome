# LSP + Language specific configurations
{
  pkgs,
  dsl,
  ...
}:
let
  cmd = command: desc: [
    "<cmd>${command}<cr>"
    desc
  ];
in
with dsl;
{
  plugins = with pkgs.vimPlugins; [
    remember-me-nvim
  ];

  # moved into whichkey
  lua = builtins.readFile ./remember-me.lua;
}
