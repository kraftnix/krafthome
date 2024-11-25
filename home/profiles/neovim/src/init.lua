vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.o.showtabline = 2

local helper = require('utils.helper')
FmDir = helper.FmDir

vim.g.enable_cmp = true
vim.g.enable_cmp_cmdline = true

-- mini.surround
vim.keymap.set({ 'n', 'x' }, 's', '<Nop>')

local confdir = '~/.config/nvim/'
local nixplugdir = confdir .. 'nix-plugins/'

-- Use nix installed lazy.nvim
local lazypath = nixplugdir .. 'lazy.nvim'
local utilspath = confdir .. 'lua/utils'
vim.opt.rtp:prepend(utilspath)
vim.opt.rtp:prepend(lazypath)
vim.opt.rtp:prepend(confdir .. 'parser')
-- vim.opt.rtp:prepend(confdir .. 'lua/helper.lua')

-- color
-- vim.cmd 'colorscheme base16-ffffff'
-- vim.cmd 'set termguicolors'

-- add transparency
-- vim.cmd 'hi Normal ctermbg=NONE guibg=NONE'
-- vim.cmd 'hi NonText ctermbg=NONE guibg=NONE'
-- vim.cmd 'hi SignColumn ctermbg=NONE guibg=NONE'

vim.cmd[[
  set guioptions-=e " Use showtabline in gui vim
  set sessionoptions+=tabpages,globals " store tabpages and globals in session
]]

require('lazy').setup( {
  {import = 'plugins'},
  {import = 'plugins.keymaps'},
  {import = 'plugins.movement'},
  {import = 'plugins.code'},
  {import = 'plugins.tools'},
  {import = 'plugins.telescope'},
  {import = 'plugins.ui'},
  -- -- {import = 'plugins.ui.wilder'},
  -- {import = 'plugins.ui.noice'},
  -- {import = 'plugins.ui.starter'},
  -- -- {import = 'plugins.ui'},
  -- {import = 'plugins.ui.lualine'},
}, {
  -- set install directory to .config
  root = '~/.config/nvim/lazy-plugins',
  install = {
    -- do not install by default, note breaks lazy's nonlazy auto-installs
    -- missing = false,
  },
  change_detection = {
    enabled = true,
    notify = false,
  },
  performance = {
    rtp = {
      paths = {
        '~/.config/nvim/lua/helper.lua',
      }
    }
  },
  ui = {
    icons = {
      cmd = "🐧",
      config = "🛠",
      event = "📅",
      ft = "📂",
      init = "🎯",
      keys = "🗝",
      plugin = "🔌",
      runtime = "💻",
      require = "🌙",
      source = "📄",
      start = "🚀",
      task = "📌",
      lazy = "💤 ",
    },
  },
  profiling = {
    -- Enables extra stats on the debug tab related to the loader cache.
    -- Additionally gathers stats about all package.loaders
    loader = true,
    -- Track each new require in the Lazy profiling tab
    require = true,
  },
})

require 'basic'
-- require 'keybindings'


-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
-- vim.keymap.set('n', '<leader>lqd', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})
