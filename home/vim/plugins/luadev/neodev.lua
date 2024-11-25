-- IMPORTANT: make sure to setup neodev BEFORE lspconfig
require("neodev").setup({
  -- add any options here, or leave empty to use the default settings
  library = {
    enabled = true,
    runtime = true,
    types = true,
    plugins = true,
  },
  setup_jsonls = true,
  lspconfig = true,
})

vim.api.nvim_set_keymap('v', '<leader>rr', '<Plug>(Luadev-Run)', { noremap = false, silent = false })
vim.api.nvim_set_keymap('n', '<leader>rr', '<Plug>(Luadev-RunLine)', { noremap = false, silent = false })
-- worse than neodev
--vim.api.nvim_set_keymap('i', '<leader>rr', '<Plug>(Luadev-Complete)', { noremap = false, silent = false })
