local h = require 'utils.helper'
return h.mapNixPlugin {

  -- had to recombine all mini.nvim into one file due to lazy-nvim changes
  -- see: https://github.com/folke/lazy.nvim/issues/1610
  { 'echasnovski/mini.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim' },
    lazy = false,
    keycommands = {
      -- move
      { '<leader>mh', ':lua require("mini.move").move_selection("left")<cr>'  , '[m]ove selection left [h]', 'MiniMoveSelectionLeft', mode = 'v' },
      { '<leader>ml', ':lua require("mini.move").move_selection("right")<cr>' , '[m]ove selection [r]ight', 'MiniMoveSelectionRight', mode = 'v' },
      { '<leader>mj', ':lua require("mini.move").move_selection("down")<cr>'  , '[m]ove selection [d]own', 'MiniMoveSelectionDown', mode = 'v' },
      { '<leader>mk', ':lua require("mini.move").move_selection("up")<cr>'    , '[m]ove selection up [k]', 'MiniMoveSelectionUp', mode = 'v' },

      { '<leader>mh', ':lua require("mini.move").move_line("left")<cr>'       , '[m]ove line left [h]', 'MiniMoveLineLeft' },
      { '<leader>ml', ':lua require("mini.move").move_line("right")<cr>'      , '[m]ove line [r]ight', 'MiniMoveLineRight' },
      { '<leader>mj', ':lua require("mini.move").move_line("down")<cr>'       , '[m]ove line [d]own', 'MiniMoveLineDown' },
      { '<leader>mk', ':lua require("mini.move").move_line("up")<cr>'         , '[m]ove line up [k]', 'MiniMoveLineUp' },

      -- pick
      { nil, 'Pick', 'Mini Pick (similar - Telescope)', 'Pick', cmd_gen_skip = true }
    },
    keys = {
      -- misc
      { '<leader>z',  ':lua require("mini.misc").zoom()<cr>',  mode = 'n', desc = '[z]oom in/out of buffer' },
      -- map
      { '<leader>lm', ':lua require("mini.map").toggle()<cr>', mode = "n", desc = "[l]: show [m]inimap of code shape in side panel" },
      { '<C-l>', function()
        require("mini.map").refresh({})
        vim.cmd("nohlsearch")
      end, mode = "n", desc = "[a] show [m]inimap of code shape in side panel" },
    },
    config = function(_, opts)
      require('mini.move').setup({
        mappings = {
          -- visual mmode assignments
          left       = '<M-H>',
          right      = '<M-L>',
          down       = '<M-J>',
          up         = '<M-K>',

          -- Move current line in Normal mode
          line_left  = '<M-H>',
          line_right = '<M-L>',
          line_down  = '<M-J>',
          line_up    = '<M-K>',
        },
        options = {
          reindent_linewise = true,
        },
      })
      require('mini.surround').setup({
        mappings = {
          add = 'sa',            -- Add surrounding in Normal and Visual modes
          delete = 'sd',         -- Delete surrounding
          find = 'sf',           -- Find surrounding (to the right)
          find_left = 'sF',      -- Find surrounding (to the left)
          highlight = 'sh',      -- Highlight surrounding
          replace = 'sr',        -- Replace surrounding
          update_n_lines = 'sn', -- Update `n_lines`

          suffix_last = 'l',     -- Suffix to search with "prev" method
          suffix_next = 'n',     -- Suffix to search with "next" method
        }
      })
      -- extra movement style plugins from `mini.nvim`
      require('mini.move').setup({})
      require('mini.operators').setup({})
      -- add '╎' to show current indentatioin
      require('mini.indentscope').setup({})
      -- doesn't appear to work at all
      require('mini.bracketed').setup({
        treesitter = { suffix = 'e', options = {} },
        indent = { suffix = '' },
      })
      local map = require('mini.map')
      map.setup({
        integrations = {
          map.gen_integration.builtin_search(),
          map.gen_integration.gitsigns(),
          map.gen_integration.diagnostic(),
        },
        -- Customize `symbols` to your liking
        symbols = {
          scroll_line = '🮚',
        },
        window = {
          focusable = true,
          -- Set this to the maximum width of your scroll symbols
          -- width = 1,
          -- Set this to your liking. Try values 0, 25, 50, 75, 100
          winblend = 25,
          show_integration_count = true,
        },
      })
      for _, key in ipairs({ 'n', 'N', '*', '#' }) do
        vim.keymap.set(
          'n',
          key,
          key ..
          '<Cmd>lua MiniMap.refresh({})<CR>'
        )
      end

      local MiniPick = require('mini.pick')
      MiniPick.setup({})
      MiniPick.registry.buffer_lines = function(local_opts)
        -- Parse options
        local_opts = vim.tbl_deep_extend('force', { buf_id = nil, prompt = '' }, local_opts or {})
        local buf_id, prompt = local_opts.buf_id, local_opts.prompt
        local_opts.buf_id, local_opts.prompt = nil, nil

        -- Construct items
        if buf_id == nil or buf_id == 0 then buf_id = vim.api.nvim_get_current_buf() end
        local lines = vim.api.nvim_buf_get_lines(buf_id, 0, -1, false)
        local items = {}
        for i, l in ipairs(lines) do
          items[i] = { text = string.format('%d:%s', i, l), bufnr = buf_id, lnum = i }
        end

        -- Start picker while scheduling setting the query
        vim.schedule(function() MiniPick.set_picker_query(vim.split(prompt, '')) end)
        MiniPick.start({ source = { items = items, name = 'Buffer lines' } })
      end

      require('mini.files').setup({})
      require('mini.sessions').setup({
        autoread = false,
        autowrite = true,
        file = 'session.vim',
      })

      -- starter
      local starter = require "mini.starter"
      starter.setup({
        evaluate_single = true,
        items = {
          starter.sections.builtin_actions(),
          { name = 'w: Open `flake.nix`',         action = [[:e flake.nix]],               section = 'Introspection' },
          { name = 'm: (Neovim) Messages',        action = [[:messages]],                  section = 'Introspection' },
          { name = 'f: Files',                    action = [[:Telescope find_files]],      section = 'Introspection' },
          { name = 'b: File Browser',             action = [[:Telescope file_browser]],    section = 'Introspection' },
          { name = 'l: Fuzzy Search (live_grep)', action = [[:Telescope live_grep]],       section = 'Introspection' },
          { name = 'g: Open Neogit',              action = [[:Neogit]],                    section = 'Introspection' },
          { name = 'p: Open Lazy',                action = [[:Lazy]],                      section = 'Introspection' },
          { name = 'c: Command History',          action = [[:Telescope command_history]], section = 'Introspection' },
          { name = 'o: File Browser',             action = [[:Oil]],                       section = 'Introspection' },
          { name = 'h: Help Tags (Neovim docs)',  action = [[:Telescope help_tags]],       section = 'Introspection' },
          starter.sections.recent_files(10, true),
          starter.sections.recent_files(5, false),
          -- Use this if you set up 'mini.sessions'
          starter.sections.sessions(5, true)
        },
        content_hooks = {
          starter.gen_hook.adding_bullet(),
          starter.gen_hook.indexing('all', { 'Builtin actions', 'Introspection' }),
          starter.gen_hook.padding(3, 2),
        },
      })
    end
  },

  -- -- move selections around
  -- { 'echasnovski/mini.move',
  --   nix_name = "mini.nvim",
  --   lazy = false, -- otherwise alt mappings dont load
  --   keycommands_meta = {
  --     description = 'Move lines and visual selections quickly',
  --     icon = '⬇',
  --     default_opts = { -- only applies to this lazy keygroup
  --       silent = true,
  --     }
  --   },
  --   keycommands = {
  --     { '<leader>mh', ':lua require("mini.move").move_selection("left")<cr>'  , '[m]ove selection left [h]', 'MiniMoveSelectionLeft', mode = 'v' },
  --     { '<leader>ml', ':lua require("mini.move").move_selection("right")<cr>' , '[m]ove selection [r]ight', 'MiniMoveSelectionRight', mode = 'v' },
  --     { '<leader>mj', ':lua require("mini.move").move_selection("down")<cr>'  , '[m]ove selection [d]own', 'MiniMoveSelectionDown', mode = 'v' },
  --     { '<leader>mk', ':lua require("mini.move").move_selection("up")<cr>'    , '[m]ove selection up [k]', 'MiniMoveSelectionUp', mode = 'v' },
  --
  --     { '<leader>mh', ':lua require("mini.move").move_line("left")<cr>'       , '[m]ove line left [h]', 'MiniMoveLineLeft' },
  --     { '<leader>ml', ':lua require("mini.move").move_line("right")<cr>'      , '[m]ove line [r]ight', 'MiniMoveLineRight' },
  --     { '<leader>mj', ':lua require("mini.move").move_line("down")<cr>'       , '[m]ove line [d]own', 'MiniMoveLineDown' },
  --     { '<leader>mk', ':lua require("mini.move").move_line("up")<cr>'         , '[m]ove line up [k]', 'MiniMoveLineUp' },
  --   },
  --   opts = {
  --     mappings = {
  --       -- visual mmode assignments
  --       left  = '<M-H>',
  --       right = '<M-L>',
  --       down  = '<M-J>',
  --       up    = '<M-K>',
  --
  --       -- Move current line in Normal mode
  --       line_left   = '<M-H>',
  --       line_right  = '<M-L>',
  --       line_down   = '<M-J>',
  --       line_up     = '<M-K>',
  --     },
  --     options = {
  --       reindent_linewise = true,
  --     },
  --   }
  -- },

  -- -- helpers with pairs of brackets/quotes
  -- -- bindings don't appear to work
  -- { 'echasnovski/mini.surround',
  --   nix_name = "mini.nvim",
  --   -- enabled = false,
  --   lazy = false,
  --   opts = {
  --     mappings = {
  --       add = 'sa',             -- Add surrounding in Normal and Visual modes
  --       delete = 'sd',          -- Delete surrounding
  --       find = 'sf',            -- Find surrounding (to the right)
  --       find_left = 'sF',       -- Find surrounding (to the left)
  --       highlight = 'sh',       -- Highlight surrounding
  --       replace = 'sr',         -- Replace surrounding
  --       update_n_lines = 'sn',  -- Update `n_lines`
  --
  --       suffix_last = 'l',          -- Suffix to search with "prev" method
  --       suffix_next = 'n',          -- Suffix to search with "next" method
  --     }
  --   },
  -- },

  -- -- extra movement style plugins from `mini.nvim`
  -- { 'echasnovski/mini.movement',
  --   nix_name = "mini.nvim",
  --   keys = {
  --     { '<leader>z', ':lua require("mini.misc").zoom()<cr>', mode = 'n', desc = '[z]oom in/out of buffer' }
  --   },
  --   opts = {}
  -- },
  -- -- `g` related operations
  -- { 'echasnovski/mini.operators',
  --   nix_name = "mini.nvim",
  --   opts = {}
  -- },
  -- -- add '╎' to show current indentatioin
  -- { 'echasnovski/mini.indentscope',
  --   nix_name = "mini.nvim",
  --   opts = {}
  -- },
  -- -- doesn't appear to work at all
  -- { 'echasnovski/mini.nvim',
  --   name = "mini.bracketed",
  --   nix_name = "mini.nvim",
  --   opts = {
  --     treesitter = { suffix = 'e', options = {} },
  --     indent = { suffix = '' },
  --   }
  -- },
  --
  -- { 'echasnovski/mini.map',
  --   nix_name = "mini.nvim",
  --   keys = {
  --     { '<leader>lm', ':lua require("mini.map").toggle()<cr>', mode = "n", desc = "[l]: show [m]inimap of code shape in side panel" },
  --     { '<C-l>', function ()
  --       require("mini.map").refresh({})
  --       vim.cmd("nohlsearch")
  --     end , mode = "n", desc = "[a] show [m]inimap of code shape in side panel" },
  --   },
  --   lazy = false,
  --   name = 'mini.map',
  --   config = function ()
  --     local map = require('mini.map')
  --     map.setup({
  --       integrations = {
  --         map.gen_integration.builtin_search(),
  --         map.gen_integration.gitsigns(),
  --         map.gen_integration.diagnostic(),
  --       },
  --       -- Customize `symbols` to your liking
  --       symbols = {
  --         scroll_line = '🮚';
  --       },
  --       window = {
  --         focusable = true,
  --         -- Set this to the maximum width of your scroll symbols
  --         -- width = 1,
  --         -- Set this to your liking. Try values 0, 25, 50, 75, 100
  --         winblend = 25,
  --         show_integration_count = true,
  --       },
  --     })
  --     for _, key in ipairs({ 'n', 'N', '*', '#' }) do
  --       vim.keymap.set(
  --         'n',
  --         key,
  --         key ..
  --           '<Cmd>lua MiniMap.refresh({})<CR>'
  --       )
  --     end
  --   end
  -- },
  --
  -- { 'echasnovski/mini.pick',
  --   cmd = 'Pick',
  --   nix_name = 'mini.nvim',
  --   keycommands = {
  --     { nil, 'Pick', 'Mini Pick (similar - Telescope)', 'Pick', cmd_gen_skip = true }
  --   },
  --   opts = {},
  -- },

  --[[

local MiniPick = require('mini.pick')
MiniPick.start({ source = { items = vim.fn.readdir('.') } })
MiniPick.registry.buffer_lines = function(local_opts)
  -- Parse options
  local_opts = vim.tbl_deep_extend('force', { buf_id = nil, prompt = '' }, local_opts or {})
  local buf_id, prompt = local_opts.buf_id, local_opts.prompt
  local_opts.buf_id, local_opts.prompt = nil, nil

  -- Construct items
  if buf_id == nil or buf_id == 0 then buf_id = vim.api.nvim_get_current_buf() end
  local lines = vim.api.nvim_buf_get_lines(buf_id, 0, -1, false)
  local items = {}
  for i, l in ipairs(lines) do
    items[i] = { text = string.format('%d:%s', i, l), bufnr = buf_id, lnum = i }
  end

  -- Start picker while scheduling setting the query
  vim.schedule(function() MiniPick.set_picker_query(vim.split(prompt, '')) end)
  MiniPick.start({ source = { items = items, name = 'Buffer lines' } })
end
MiniPick.start()

local pick = require('mini.pick')

pick.registry.grep_live_current_buf = function()
  local lines = vim.api.nvim_buf_get_lines(0, 1, -1, false)
  local items = {}

  local path = vim.fn.expand('%p')
  for lnum, line in ipairs(lines) do
    items[lnum] = { text = line, lnum = lnum + 1, path = path }
  end

  pick.start({
    source = {
      items = items,
      name = 'Grep current buffer',
    },
  })
  pick.set_picker_query(vim.split(vim.fn.expand('<cword>'), ''))
end

pick.start()

  --]]


}
