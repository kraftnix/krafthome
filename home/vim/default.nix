zargs@{
  inputs,
  self,
  ...
}:
args@{
  lib,
  config,
  pkgs,
  ...
}:
with builtins;
with pkgs.lib;
let
  inherit (config.lib) base16;
  colorName = "base16-${base16.theme.scheme-slug}";
  vimColors = base16.programs.vim;
  #extendedPkgs = (inputs.nixpkgs.extend inputs.nix2vim.overlay)
  # extendedPkgs = (pkgs.extend inputs.nix2vim.overlay)
  #   .extend (_: prev: self.packages.${pkgs.system} // {
  #     vimPlugins = prev.vimPlugins // self.vimPlugins.${pkgs.system};
  #   #.extend (_: _: cell.packages // {
  #     #vimPlugins = inputs.nixpkgs.vimPlugins // cell.vimPlugins;
  #   });
  extendedPkgs = pkgs;
in
{
  home.file = mkMerge [
    # (mkIf config.khome.themes.enable {
    {
      # ".config/nvim/colors/${colorName}.vim".source = vimColors.template "vim";
      # ".config/nvim/autoload/airline-${colorName}.vim".source = base16.getTemplate "vim-airline-themes";
      ".config/nvim/parser/nu.so".source = "${extendedPkgs.tree-sitter-full.builtGrammars.tree-sitter-nu}/parser";
    }
  ];
  home.packages = [ pkgs.neovim-remote ];
  programs.neovim.enable = true;
  # alias nvimb for an always working version
  home.sessionVariables.EDITOR = lib.mkOverride 500 "nvim";
}
