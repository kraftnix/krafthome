-- Highlight, edit, and navigate code
local h = require 'utils.helper'
local nixplugdir = require('utils.lazy_nix').nixplugdir
local user = vim.fn.getenv("USER")

return h.mapNixPlugin {

  { 'nvim-treesitter/nvim-treesitter-context',
    opts = {
      enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
      max_lines = 4, -- How many lines the window should span. Values <= 0 mean no limit.
      min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
      line_numbers = true,
      multiline_threshold = 20, -- Maximum number of lines to collapse for a single context line
      trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
      -- mode = 'cursor',  -- Line used to calculate context. Choices: 'cursor', 'topline'
      mode = 'topline',
      -- Separator between context and content. Should be a single character string, like '-'.
      -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
      separator = nil,
      zindex = 20, -- The Z-index of the context window
      on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
    }
  },

  { 'JoosepAlviste/nvim-ts-context-commentstring',
    dependencies = { 'nvim-treesitter/nvim-treesitter' }
  },

  -- causes compilation of treesitter with using lazy
  -- nix package doesn't work with lazy
  { 'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/playground',
      'nvim-treesitter/nvim-treesitter-context',
      'nvim-treesitter/nvim-treesitter-refactor',
      'nvim-treesitter/nvim-treesitter-textobjects',
      'RRethy/nvim-treesitter-textsubjects',
    },
    config = function ()

      vim.opt.rtp:prepend(nixplugdir .. "nvim-treesitter-parsers")

      ---@diagnostic disable-next-line: missing-fields
      require('nvim-treesitter.configs').setup {
        -- cannot be used when using nixpkgs nvim-treesitter
        -- Add languages to be installed here that you want installed for treesitter
        -- ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'typescript', 'vimdoc', 'vim' },

        -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
        auto_install = false,

        -- parser_install_dir = nixplugdir .. "nvim-treesitter-parsers",
        parser_install_dir = "/home/"..user.."/.config/nvim/parser",

        highlight = { enable = true },
        rainbow = { enable = true, },
        autotag = { enable = true, },
        indent = { enable = false, }, -- behaviours weirdly on nix
        incremental_selection = {
          enable = true,
          keymaps = {
            -- init_selection = "gnn",
            -- node_incremental = "grn",
            -- scope_incremental = "grc",
            -- node_decremental = "grm",
            init_selection = '<c-space>',
            node_incremental = '<c-space>',
            scope_incremental = '<c-s>',
            node_decremental = '<M-space>',
          },
        },
        query_linter = {
          enable = true,
          use_virtual_text = true,
          lint_events = { "BufWrite", "CursorHold" },
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
            keymaps = {
              -- You can use the capture groups defined in textobjects.scm
              ['aa'] = '@parameter.outer',
              ['ia'] = '@parameter.inner',
              ['af'] = '@function.outer',
              ['if'] = '@function.inner',
              ['ac'] = '@class.outer',
              ['ic'] = '@class.inner',
            },
          },
          move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
              [']r'] = '@parameter.inner',
              [']m'] = '@function.outer',
              [']]'] = '@class.outer',
              ["]s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
              ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
            },
            goto_next_end = {
              [']R'] = '@parameter.inner',
              [']M'] = '@function.outer',
              [']['] = '@class.outer',
              ["]S"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
              ["]Z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
            },
            goto_previous_start = {
              ['[r'] = '@parameter.inner',
              ['[m'] = '@function.outer',
              ['[['] = '@class.outer',
              ["[s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
              ["[z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
            },
            goto_previous_end = {
              ['[R'] = '@parameter.inner',
              ['[M'] = '@function.outer',
              ['[]'] = '@class.outer',
              ["[S"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
              ["[Z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
            },
          },
          lsp_interop = {
            enable = true,
            border = 'none',
            floating_preview_opts = {},
            peek_definition_code = {
              ["<leader>df"] = "@function.outer",
              ["<leader>dF"] = "@class.outer",
            },
          },
          swap = {
            enable = true,
            swap_next = {
              ['<leader>mn'] = '@parameter.inner',
            },
            swap_previous = {
              ['<leader>mp'] = '@parameter.inner',
            },
          },
        },
        textsubjects = {
            enable = true,
            prev_selection = ',', -- (Optional) keymap to select the previous selection
            keymaps = {
                ['.'] = 'textsubjects-smart',
                [';'] = 'textsubjects-container-outer',
                ['i;'] = 'textsubjects-container-inner',
            },
        },
        refactor = {
          highlight_definitions = {
            enable = true,
            clear_on_cursor_move = true,
          },
          highlight_current_scope = true,
          smart_rename = {
            enable = true,
            -- Assign keymaps to false to disable them, e.g. `smart_rename = false`.
            keymaps = {
              smart_rename = "<leader>rNt",
            },
          },
        },
        navigation = {
          enable = true,
          -- Assign keymaps to false to disable them, e.g. `goto_definition = false`.
          keymaps = {
            goto_definition = "gnd",
            list_definitions = "gnD",
            list_definitions_toc = "gO",
            goto_next_usage = "<a-*>",
            goto_previous_usage = "<a-#>",
          },
        },
        playground = {
          enable = true,
          disable = {},
          updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
          persist_queries = false, -- Whether the query persists across vim sessions
          keybindings = {
            toggle_query_editor = 'o',
            toggle_hl_groups = 'i',
            toggle_injected_languages = 't',
            toggle_anonymous_nodes = 'a',
            toggle_language_display = 'I',
            focus_language = 'f',
            unfocus_language = 'F',
            update = 'R',
            goto_node = '<cr>',
            show_help = '?',
          },
        }
      }
      -- vim.treesitter.language.add('nu', { path = vim.fn.stdpath("config") .. "/parser/nu.so" })
      -- vim.filetype.add({ extension = { nu = "nu" } })
    end
  }
}
