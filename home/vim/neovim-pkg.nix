{...}: {
  imports = [
    ./plugins/essentials.nix
    ./plugins/style.nix
    ./plugins/telescope
    ./plugins/comment
    ./plugins/cmp
    ./plugins/treesitter
    ./plugins/lspkind
    # ./plugins/wilder
    ./plugins/fugitive.nix
    ./plugins/nvim-tree.nix
    # ./plugins/telescope-hop
    ./plugins/telescope-project
    ./plugins/fzf-vim.nix
    ./plugins/lsp
    ./plugins/toggleterm.nix
    ./plugins/neozoom.nix
    ./plugins/fm.nix
    ./plugins/gitlinker
    ./plugins/luadev
    ./plugins/ssh-reset.nix
    ./plugins/leap.nix
    # ./plugins/remember-me
  ];
  withPython3 = true;
  withNodeJs = true;
}
