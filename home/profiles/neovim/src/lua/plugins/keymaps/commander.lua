local h = require 'utils.helper'
return h.mapNixPlugin {

  { 'FeiyouG/commander.nvim',
    nix_name = 'commander-nvim',
    dependencies = { "nvim-telescope/telescope.nvim", },
    config = function()
      require("commander").setup({
        components = {
          "DESC",
          "KEYS",
          "CAT",
        },
        sort_by = {
          "DESC",
          "KEYS",
          "CAT",
          "CMD"
        },
        integration = {
          telescope = {
            enable = true,
          },
          lazy = {
            enable = true,
            set_plugin_name_as_cat = true
          }
        }
      })
      -- local keycommands = require 'utils.keycommands'.KeyCommands
      -- local commands = keycommands:getCommanderCommands()
      -- local keymaps = keycommands:getCommanderKeymaps()
      -- require('commander').add(cmds, { show = true, set = false })

      -- require('commander').add({{
      --   desc = 'fuckerdesc',
      --   cmd = function()
      --     require('telescope.builtin').autocommands()
      --   end,
      --   -- keys = { keymap.modes, keymap.map, keymap.opts },
      --   cat = 'fuck'
      -- }}, { show = true })

      -- vim.api.nvim_create_user_command('FUCKEXAMPLE111', function (opts)
      --     -- vim.print('Hello WORLD--',opts,'--')
      --     vim.print('Hello WORLD----')
      --   end, {})
      -- -- vim.api.('n','<leader>fte', '', {
      -- --   callback = function (opts)
      -- --     vim.print('Hello WORLD--',opts,'--')
      -- --   end,
      -- --   desc = 'fuuuuuck HELLO'
      -- -- })
      -- local kc = require('keycommands')
      -- local keycommand = kc.map_keycommand({
      --   'ExampleHellowWorld',
      --   function()
      --     print('hello world!')
      --   end,
      --   'Hello world description',
      --   '<leader>fH',
      --   'Example'
      -- })
      -- kc.print('keycommnad', keycommand)
      -- local km = kc.map_key(keycommand)
      -- kc.print('km', km)
      -- for i, mode in ipairs(km.modes) do
      --   vim.api.nvim_set_keymap(mode,km.map,km.cmd,km.opts)
      -- end
    end,
  },

}
