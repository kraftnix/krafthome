# Completion engine for neovim
{
  pkgs,
  dsl,
  ...
}:
with dsl;
{
  plugins = with pkgs.vimPlugins; [
    nvim-lspconfig
    lsp_signature-nvim
    lspkind-nvim
    nvim-cmp
    cmp-nvim-lsp
    cmp-buffer
    cmp-vsnip
    cmp-path
    cmp-nixpkgs
    cmp-cmdline
    cmp-cmdline-history
  ];

  setup.lsp_signature = {
    bind = true;
    hint_enable = false;
    hi_parameter = "Visual";
    handler_opts.border = "single";
  };

  lua = builtins.readFile ./cmp.lua;
}
