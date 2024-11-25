local h = require 'utils.helper'
local make_telescope_command = h.make_telescope_command

-- load an initial core outside KeyCommander

-- better indenting
-- map("v", "<", "<gv")
-- map("v", ">", ">gv")

-- require("noice").redirect(function()
--   vim.print("test")
-- end, {
--   -- routes = {{
--   --   view = 'split',
--   -- }},
--   view = 'mini' --doesn't work
--   -- filter = { event = "msg_show", },
--   -- opts = { skip = true },
-- })

-- vim.keymap.set("c", "<C-Enter>", function()
--   require("noice").redirect(vim.fn.getcmdline())
-- end, { desc = "Redirect Cmdline" })

return {

  ---SSH
  { itemgroup = 'SSH',
    icon = '󰣀',
    description = 'SSH operations',
    keymaps = {
      { '<leader>skk',
        h.update_ssh_auth_sock,
        desc = 'Reload SSH key'
      },
      { '<leader>skl',
        function()
          vim.notify('SSH_AUTH_SOCK: '..vim.env.SSH_AUTH_SOCK, 'info')
          -- require('noice').redirect('echo $SSH_AUTH_SOCK')
        end,
        desc = 'Show current `SSH_AUTH_SOCK` value'
      },
    },
  },

  ---neovim
  { itemgroup = 'Neovim',
    icon = '',
    description = 'Neovim helpers',
    keymaps = {
      make_telescope_command {
        'fvf',
        h.tb_wrap('find_files', '~/.config/nvim', { search_dirs = { '~/.config/nvim/nix-plugins', '~/.config/nvim/lazy-plugins' } }),
        'Find in installed current neovim plugins',
      },
      make_telescope_command {
        'fvg',
        h.tb_wrap('live_grep', '~/.config/nvim', { search_dirs = { '~/.config/nvim/nix-plugins', '~/.config/nvim/lazy-plugins' } }),
        'Fuzzy search in installed current neovim plugins',
      },
    },
  },

  --- nix
  { itemgroup = 'Nix',
    icon = '❄️',
    description = 'Nix Commands',
    keymaps = {
      make_telescope_command {
        'fnfl',
        require'utils.telescope.flake'.flake_picker,
        'Telesope picker for Nix Flake Inputs, update/view inputs',
      },
      make_telescope_command {
        'fnpf',
        h.tb_wrap('find_files', '~/repos/NixOS/nixpkgs'),
        'Find files in Nix Packages',
      },
      make_telescope_command {
        'fnpg',
        h.tb_wrap('live_grep', '~/repos/NixOS/nixpkgs'),
        'Fuzzy search in Nix Packages',
      },
      make_telescope_command {
        'fnpdf',
        h.tb_wrap('find_files', '~/repos/NixOS/nixpkgs', { find_command = { 'fd', '-e', 'md', '-e', 'txt' }}),
        'Find files in Nix Packages',
      },
      make_telescope_command {
        'fnpdg',
        h.tb_wrap('live_grep', '~/repos/NixOS/nixpkgs', {type_filter='markdown'}),
        'Fuzzy search in Nix Packages',
      },
      { '<leader>fnpt',
        function()
          print('hello world!')
        end,
        description = 'Say hello as a command',
      },
      -- (make_telescope_command({ 'fnpf', function ()
      --   require('telescope.builtin').find_files({ search_dirs = { "%:p" } })
      -- end, '[fJ] Fuzzy search in current directory' })),
    },
  },

  -- movement
  { itemgroup = 'movement',
    icon = '➡',
    description = 'General Movement Options',
    keymaps = {
      h.mapSilent { 'H', ':tabp<cr>', description = 'Go to previous tab', },
      h.mapSilent { 'L', ':tabn<cr>', description = 'Go to next tab', },
      h.mapSilent { '<leader>wJ', ':bprev<cr>', desc = '[J]: Previous buffer', },
      h.mapSilent { '<leader>wK', ':bnext<cr>', desc = '[K]: Next buffer', },
      h.mapSilent { '<leader>wh', ':wincmd h<cr>', description = 'Move cursor to buffer left', },
      h.mapSilent { '<leader>wj', ':wincmd j<cr>', description = 'Move cursor to buffer below', },
      h.mapSilent { '<leader>wk', ':wincmd k<cr>', description = 'Move cursor to buffer above', },
      h.mapSilent { '<leader>wl', ':wincmd l<cr>', description = 'Move cursor to buffer right', },
    },
  },

  -- buffer mgmt
  { itemgroup = 'buffer management',
    icon = '',
    description = 'Manage vim buffers',
    keymaps = {
      h.mapSilent { '<leader>wD', ':Bclose!<cr>', desc = '[D]elete buffer aggressively', },
      h.mapSilent { '<leader>wd', ':bd<cr>', desc = '[d]elete buffer', },
      h.mapSilent { '<leader>wq', ':close<cr>', desc = '[q]: Close buffer', },
      h.mapSilent { '<leader>wQ', ':q!<cr>', desc = '[Q]: Hard Close nvim', },
      h.mapSilent { '<leader>wt', ':tabedit<cr>', desc = '[t]ab edit', },
      h.mapSilent { '<leader>wv', ':vs<cr>', desc = 'Split window [v]ertically', },
      h.mapSilent { '<leader>ws', ':w<cr>', desc = '[s]: save file (:w)', },
      h.mapSilent { '<leader>ww', ':Telescope buffers<cr>', desc = '[w]: Get buffer list', },
      h.mapSilent { '<leader>wx', ':sp<cr>', desc = '[x]: Split window horizontally', },
      h.mapSilent { '<leader>re', ':e!<cr>', desc = '[r][e]load (forced) current buffer', },
    },
  },

}
