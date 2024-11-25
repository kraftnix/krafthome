local h = require 'utils.helper'
local user = vim.fn.getenv("USER")
return h.mapNixPlugin {
  { 'mrjones2014/legendary.nvim',
    dependencies = {
      'kkharji/sqlite.lua',
    },
    -- lazy = false,
    priority = 20000,
    keycommands_meta = {
      --source_plugin = legendary (from lazy.main)
      group_name = 'Key map tools',
      description = 'Legendary, WhichKey, Commander and my own keymap thingie',
      icon = '⌨',
      default_opts = { -- only applies to this lazy keygroup
        silent = true,
      }
    },
    keycommands = {
      h.mapSkipGen { nil, 'WhichKey', 'Open WhichKey' },
      h.mapSkipGen { "<leader>=", 'Legendary', 'Open Legendary' },
      h.mapSkipGen { "<leader>lll", 'Lazy', 'Open Lazy', },
    },
    config = function()
      vim.api.nvim_set_keymap('n', '<leader>llL', '<cmd>tabe ' .. user .. '/xdg/.cache/nvim/KeyCommands<cr>',
        { noremap = false, silent = false })
      local legendary = require 'legendary'
      local commands = require 'commands'
      local keycommands = require 'utils.keycommands'
      keycommands:parseFromLazy()
      local lk = keycommands:getLegendaryKeymaps()
      -- vim.print(lk)
      local keymaps = h.concat_tables(
        lk,
        require 'keybindings'
      )
      legendary.setup({
        extensions = {
          lazy_nvim = true,
          which_key = { auto_register = true, use_groups = true },
          diffview = true,
          nvim_tree = true,
        },
        keymaps = keymaps,
        commands = commands,
      })
      -- keycommands:setKeymaps()
      -- keycommands:setUserCommands()
      -- keycommands:getLegendaryKeymaps()
      -- keycommands:print('legendary-keymaps', vim.print)
      -- local a = keycommands:getKeycommands('Key map tools')
      -- keycommands.log('info', keycommands:toTable())
      -- vim.print(keycommands.groups)

      -- mycommands:parse_from_lazy():print('keymaps')
      -- local kc = require('keycommands')
      -- kc.map_lazy_keys()
      -- kc.map_lazy_commands()
    end
  },
}
