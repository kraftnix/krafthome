local h = require 'utils.helper'
-- local jqx = vim.api.nvim_create_augroup("Jqx", {})
-- vim.api.nvim_clear_autocmds({ group = jqx })
-- vim.api.nvim_create_autocmd("BufWinEnter", {
--     pattern = { "*.json", "*.yaml" },
--     desc = "preview json and yaml files on open",
--     group = jqx,
--     callback = function()
--         vim.cmd.JqxList()
--     end,
-- })
return h.mapNixPlugin {

  -- { "gennaro-tedesco/nvim-jqx",
  --   nix_disable = true,
  --   init = function()
  --       local jqx = require("nvim-jqx.config")
  --       jqx.geometry.border = "single"
  --       jqx.geometry.width = 0.7
  --       jqx.query_key = "X"         -- keypress to query jq on keys
  --       jqx.sort = false            -- show the json keys as they appear instead of sorting them alphabetically
  --       jqx.show_legend = true      -- show key queried as first line in the jqx floating window
  --       jqx.use_quickfix = false    -- if you prefer the location list
  --   end,
  -- },

  -- "gc" to comment visual regions/lines
  { 'numToStr/comment.nvim',
    -- enabled = false,
    opts = {
      padding = true,
      sticky = true,
      toggler = {
        line = 'gcc',
        block = 'gbc',
      },
    }
  },

  -- use `!!` to use sudo to write as root
  { 'lambdalisue/suda.vim',
    nix_name = 'vim-suda',
    keycommands = {
      h.mapSkipGen { 'w!!',
        'SudaWrite',
        "Escalate privileges with sudo and write current buffer",
        modes = { 'c' },
        cmd_gen_skip = true,
      },
    }
  },

  -- -- clipboard + macro manager
  -- { 'AckslD/nvim-neoclip.lua',
  --   dependencies = {
  --     'nvim-telescope/telescope.nvim',
  --     'kkharji/sqlite.lua',
  --     'mrjones2014/legendary.nvim',
  --   },
  --   opts = {
  --     enable_macro_history = true,
  --     enable_persistent_history = true,
  --     history = 100,
  --     keys = {
  --       telescope = {
  --         i = {
  --           paste_behind = "<c-P>",
  --         },
  --       },
  --     },
  --   },
  --   config = function (_, opts)
  --     require('neoclip').setup(opts)
  --     require('telescope').load_extension('neoclip')
  --     local lt = require('legendary.toolbox')
  --     require('legendary').keymap({
  --       itemgroup = 'LSP Mappings',
  --       icon = '📜',
  --       description = 'LSP related commands.',
  --       keymaps = {
  --         { '<leader>fc',
  --           lt.lazy_required_fn('telescope', 'extensions.neoclip.default'),
  --           desc = '[f]ind [c]lipboard entries', mode = { 'n' },
  --         },
  --         { '<leader>fm',
  --           lt.lazy_required_fn('telescope', 'extensions.macroscope.default'),
  --           desc = '[f]ind [m]acro entries', mode = { 'n' },
  --         },
  --       }
  --     })
  --   end
  -- },

  -- increment / decrement colors/dates/etc.
  { "monaqa/dial.nvim",
    keycommands_meta = {
      description = 'Increment / Decrement Anything with Dial',
      icon = '⚙',
      default_opts = {
        noremap = true,
        is_nvim_command = true,
      }
    },
    keycommands = {
      -- { "<M-n>", '<Plug>(dial-decrement)', "Smart Decrement (dial)", "DialDecrement", modes = {'v','n'} },
      -- { "<M-m>", '<Plug>(dial-increment)', 'Smart Increment (dial)', "DialIncrement", modes = {'v','n'} },
    },
    keys = {
      { mode = "v", "<M-m>", '<Plug>(dial-increment)', desc = 'smart increment (dial)', noremap = true},
      { mode = "v", "<M-n>", '<Plug>(dial-decrement)', desc = 'smart decrement (dial)', noremap = true},
      { mode = "n", "<M-m>", '<Plug>(dial-increment)', desc = 'smart increment (dial)', noremap = true},
      { mode = "n", "<M-n>", '<Plug>(dial-decrement)', desc = 'smart decrement (dial)', noremap = true},
    },
    config = function()
      local augend = require("dial.augend")
      local conf = require('dial.config').augends
      conf:register_group({
        default = {
          augend.integer.alias.decimal,
          augend.integer.alias.hex,
          augend.date.alias["%Y/%m/%d"],
          augend.constant.alias.bool,
          augend.constant.new({ elements = { "let", "const" } }),
          augend.semver.alias.semver,
          augend.hexcolor.new({
            case = "lower"
          }),
        },
      })
    end,
  },

  { "cshuaimin/ssr.nvim",
    keycommands = {
      { "<leader>sR",
        h.lr("ssr", 'open'),
        "Structural Replace",
        "StructuralReplace",
        mode = { "n", "x" },
      },
    },
    opts = {
      keymaps = {
        close = "q",
        next_match = "n",
        prev_match = "N",
        replace_confirm = "<cr>",
        replace_all = "<leader><cr>",
      },
    }
  },

}
