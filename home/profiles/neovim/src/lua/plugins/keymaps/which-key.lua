--[[
--  I would prefer to just use mini.nvim since I prefer the look
--  however it doesn't support movement operators as well as
--  which-key like `v`, `i`, `a`, `]`
--
--  So to make them interoperable, some finessing is required
--]]

local h = require 'utils.helper'
return h.mapNixPlugin {
  -- -- old which-key configurations
  { 'folke/which-key.nvim',
    dependencies = { 'mrjones2014/legendary.nvim' },
    event = "VeryLazy",
    -- lazy = false,
    -- enabled = false,
    init = function()
      vim.o.timeout = true
      -- vim.o.timeoutlen = 300
      -- vim.o.timeoutlen = 1000
      vim.o.timeoutlen = 0
    end,
    keycommands = {
      { '<C-E>', 'WhichKey', 'Open WhichKey', modes = { 'n', 'v', 't' } }
    },
    opts = {
      -- add operators that will trigger motion and text object completion
      -- to enable all native operators, set the preset / operators plugin above
      -- operators = { gc = "Comments" },
      -- key_labels = {
      --   -- override the label used to display some keys. It doesn't effect WK in any other way.
      --   -- For example:
      --   -- ["<space>"] = "SPC",
      --   -- ["<cr>"] = "RET",
      --   -- ["<tab>"] = "TAB",
      -- },
      -- motions = {
      --   count = true,
      -- },
      icons = {
        breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
        separator = "➜", -- symbol used between a key and it's label
        group = "+", -- symbol prepended to a group
      },
      -- popup_mappings = {
      --   scroll_down = "<c-d>", -- binding to scroll down inside the popup
      --   scroll_up = "<c-u>", -- binding to scroll up inside the popup
      -- },
      -- window = {
      --   border = "none", -- none, single, double, shadow
      --   position = "bottom", -- bottom, top
      --   margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]. When between 0 and 1, will be treated as a percentage of the screen size.
      --   padding = { 1, 2, 1, 2 }, -- extra window padding [top, right, bottom, left]
      --   winblend = 0, -- value between 0-100 0 for fully opaque and 100 for fully transparent
      --   zindex = 1000, -- positive value to position WhichKey above other floating windows.
      -- },
      layout = {
        height = { min = 4, max = 25 }, -- min and max height of the columns
        width = { min = 20, max = 50 }, -- min and max width of the columns
        spacing = 3, -- spacing between columns
        align = "left", -- align columns left, center or right
      },
      -- ignore_missing = false, -- enable this to hide mappings for which you didn't specify a label
      -- hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "^:", "^ ", "^call ", "^lua " }, -- hide mapping boilerplate
      show_help = true, -- show a help message in the command line for using WhichKey
      show_keys = true, -- show the currently pressed key and its label as a message in the command line
      -- triggers = "auto", -- automatically setup triggers
      triggers = {
        { "<auto>", mode = "nxso" },
        { "<leader>", mode = "nv" },
        { "s", mode = "nv" }
      }, -- or specifiy a list manually
      -- list of triggers, where WhichKey should not wait for timeoutlen and show immediately
      -- delay = {
      --   -- marks
      --   "`",
      --   "'",
      --   "g`",
      --   "g'",
      --   -- registers
      --   '"',
      --   "<c-r>",
      --   -- spelling
      --   "z=",
      --   -- mini.surround
      --   "s"
      -- },
      -- triggers_blacklist = {
      --   -- list of mode / prefixes that should never be hooked by WhichKey
      --   -- this is mostly relevant for keymaps that start with a native binding
      --   i = { "j", "k" },
      --   v = { "j", "k" },
      -- },
      -- disable the WhichKey popup for certain buf types and file types.
      -- Disabled by default for Telescope
      disable = {
        buftypes = {},
        filetypes = {},
      },
    },
    config = function(_, opts)
      local wk = require "which-key"
      wk.setup(opts)
      wk.add({
        { "s", group = "mini.[s]urround" },

        { "<leader>d", group = "[d]ap" },

        { "<leader>f", group = "[f]ind (telescope)" },
        { "<leader>fn", group = "[n]ix related" },
        { "<leader>fnp", group = "[p]ackages" },
        { "<leader>fv", group = "neo[v]im related" },

        { "<leader>g", group = "[g]it" },
        { "<leader>gd", group = "[d]iff" },
        { "<leader>gf", group = "[f]ind" },
        { "<leader>gg", group = "[git signs]" },
        { "<leader>gp", group = "[p]ull/[P]ush" },

        { "<leader>h", group = "[h]arpoon" },

        { "<leader>l", group = "[l]sp and list" },
        { "<leader>la", group = "[a]: file browsers + extra" },
        { "<leader>ll", group = "[l]: extra" },
        { "<leader>lw", group = "[w]orkspace" },

        { "<leader>m", group = "[m]ove" },
        { "<leader>n", group = "[n]oice" },
        { "<leader>r", group = "[r]eload operations" },
        { "<leader>s", group = "[s]nippet or flash" },
        { "<leader>sk", group = "[k]eys" },
        { "<leader>t", group = "[t]erminal" },
        { "<leader>w", group = "[w]indow management" },
        -- testing
        { "<leader>b", group = "buffers", expand = function()
          return require("which-key.extras").expand.buf()
        end
        },
      })
    end,
  },

}
