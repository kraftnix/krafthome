# Syntax highlighting for most languages using ASTs
{
  pkgs,
  dsl,
  ...
}:
with dsl; {
  plugins = with pkgs.vimPlugins; [
    nvim-treesitter-all
    nvim-treesitter
    nvim-treesitter-context
    rainbow-delimiters-nvim
    # playground # playground for treesitter
  ];
  lua = builtins.readFile ./treesitter.lua;
}
