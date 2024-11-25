local h = require 'utils.helper'
local defaults = require 'utils.telescope.defaults'

-- print(vim.inspect(make_telescope_command({'?', cmd = 'oldfiles', desc = 'Find recently opened files' })))

-- vim.print(require'telescope-all-recent'.config())
return h.mapNixPlugin {

  --- search firefox bookmarks from neovim
  { 'dhruvmanila/browser-bookmarks.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim', },
    keycommands = {
      { '<leader>fb', "Telescope bookmarks", '[f]ind [b]ookmarks in from your browser', 'TelescopeBookmarks', group = 'Telescope' }, --cool
    },
    opts = { selected_browser = 'firefox' },
  },

  --- menu toggles inside of telescope
  { 'molecule-man/telescope-menufacture',
    nix_name = 'telescope-menufacture',
    dependencies = { 'nvim-telescope/telescope.nvim', },
    keycommands_meta = { default_group = 'Telescope' },
    keycommands = {
      { '<leader>ff', h.lr('telescope', 'extensions.menufacture.find_files'), '[f]ind [f]iles in whole project', 'TelescopeFindFiles' },
      { '<leader>fg', h.lr('telescope', 'extensions.menufacture.live_grep'), '[fg] fuzzy search whole project', 'TelescopeLiveGrep' },
      { '<leader>fw', h.lr('telescope', 'extensions.menufacture.grep_string'), '[f]uzzy search [w]ord under your cursor', 'TelescopeGrepString' },
    },
    config = function ()
      require'telescope'.load_extension 'menufacture'
    end
  },

  { 'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'LinArcX/telescope-env.nvim',
      'debugloop/telescope-undo.nvim',
      { 'prochri/telescope-all-recent.nvim', nix_name = 'telescope-all-recent' },
      'LukasPietzschmann/telescope-tabs',
      'MrcJkb/telescope-manix',
      'nvim-telescope/telescope-cheat.nvim',
      'nvim-telescope/telescope-file-browser.nvim',
      'nvim-telescope/telescope-live-grep-args.nvim',
      'tsakirist/telescope-lazy.nvim',
      'nvim-telescope/telescope-fzf-native.nvim',
      'jvgrootveld/telescope-zoxide',
      'nvim-telescope/telescope-project.nvim',
      -- { 'nvim-telescope/telescope-smart-history.nvim', nix_disable = true }, -- requires sqlite---doesntwork
    },
    cmd = 'Telescope',
    keycommands_meta = {
      group_name = 'Telescope',
      description = 'Search for all the things',
      icon = '🔱',
      default_opts = { -- only applies to this lazy keygroup
        silent = true,
      }
    },
    keycommands = {

      -- Telescope Main
      { '<leader><space>', 'Legendary', '[ ] Open Legendary', nil },
      { '<leader><C-space>', 'Telescope commander', '[ ] Open commander', nil },
      { '<leader>f<space>', "Telescope", '[f]ind [T]elescope all builtins/extensions', nil },--gd but low prio
      { '<leader>?', 'Telescope oldfiles', '[?] Find recently opened files', 'TelescopeOldFiles' },
      { '<leader>f:', "Telescope commands", '[f:] Telescope Command Picker', 'TelescopeCommands' },--useful
      { '<leader>f;', "Telescope command_history", '[f;] Command History', 'TelescopeCommandHistory' }, --gd-ish

      -- Telescope Core Extra
      { '<leader>f-', "Telescope file_browser", '[f-] Telescope File Browser', 'TelescopeFileBrowser' }, --dunno how to use

      -- Neovim related
      { '<leader>fvh', "Telescope help_tags", 'Neovim manpages search', 'TelescopeHelpTags', group = 'Neovim' },--essential
      { '<leader>fvH', "Telescope highlights", 'Neovim highlights search', 'TelescopeHighlights', group = 'Neovim' },
      { '<leader>fvl', "Telescope lazy", '[f]ind [l]azy installed plugins', 'TelescopeLazy', group = 'Neovim' }, --nice
      { '<leader>fvk', "Telescope keymaps", '[f]ind mapped [k]ey bindings', 'TelescopeKeymaps', group = 'Neovim' },--gd
      { '<leader>fvo', "Telescope vim_options", 'find (neo)vim options', 'TelescopeVimOptions', group = 'Neovim' },
      { '<leader>fvj', "Telescope jumplist", 'find vim jumplist', 'TelescopeVimJumplist', group = 'Neovim' },

      -- Telescope Ops
      { '<leader>fr', "Telescope resume", '[f]ind [r]esume (last command)', 'TelescopeResume' },--gd
      { '<leader>ft', h.lr("telescope-tabs", "list_tabs"), '[f]ind [t]abs', 'TelescopeTabs' },--gd

      -- Extra
      { '<leader>fE', "Telescope env", '[f]ind [E]nvironment Variables (ENV)', 'TelescopeEnv' }, --notwork
      { '<leader>fu', "Telescope undo", '[f]ind [u]ndo tree', 'TelescopeUndoTree' }, --hmm
      { '<leader>fZ', "Telescope cheat", '[fz] find cheatsheets', 'TelescopeCheat' }, --notwork
      { '<leader>fz', "Telescope zoxide list", '[f]ind [z]oxide links', 'TelescopeZoxide' }, --nice
      { '<leader>fp', "Telescope project display_type=full", '[f]ind [p]rojects', 'TelescopeProjects' }, --nice

      -- Code / File Search
      { '<leader>fe', "Telescope diagnostics", '[f]ind [e]rrors / diagnostics', 'TelescopeDiagnostics' },
      { '<leader>fq', "Telescope quickfix", '[f]ind [q]uickfix list', 'TelescopeQuickFix' },
      { '<leader>fl', h.tb('live_grep', { grep_open_files=true }), '[f] Fuzzy search in a[l]l open buffers', 'TelescopeFuzzyInAllBuffers' },
      { '<leader>f~', h.tb('find_files', { search_dirs={'~'} }), '[f~] Fuzzy search in home directory', 'TelescopeFindHome' },
      { '<leader>f.', h.tb_wrap('find_files', '%:p:h'), '[f.] Fuzzy search in current directory', 'TelescopeFindCurrDir' },
      { '<leader>fJ',
        function ()
          local dir = h.get_current_buf_dir()
          h.tb('live_grep', {search_dirs = { dir }, cwd = dir })()
        end,
        '[fJ] Fuzzy search in current directory', 'TelescopeFuzzyCurrBufferDirectory',
      },
      { '<leader>fj',
        h.tb('current_buffer_fuzzy_find', h.lr('telescope.themes', 'get_dropdown', {
          winblend = 20,
          previewer = false,
        })()),
        '[fj] Fuzzily search in current buffer', 'TelescopeFuzzyInBuffer',
      },
    },

    opts = {

      defaults = {
        -- history = {
        --   path = '~/.local/share/nvim/databases/telescope_history.sqlite3',
        --   limit = 100,
        -- },
        winblend = 0,
        preview = { treesitter = true },
        vimgrep_arguments = defaults.vimgrep_core,
        sorting_strategy = "descending",
        layout_strategy = 'vertical',
        layout_config = {
          height = 0.95,
          preview_cutoff = 1,
        },
        previewer = true,
      },

      -- show hidden files
      pickers = {
        find_files = defaults.find_files,
        buffers = defaults.buffers,
      },

      --- extensions configuration
      extensions = {
        menufacture = {
          vimgrep_arguments = defaults.vimgrep_core,
          pickers = {
            find_files = defaults.find_files,
            buffers = defaults.buffers,
          },
          mappings = {
            main_menu = { [{ 'i', 'n' }] = '<C-f><C-f>' },
          },
        },
        project = {
          base_dirs = {
            '~/config',
            '~/repos',
            '~/work',
            '~/notes',
          },
        },
      },

    },

    config = function (_, opts)

      local telescope = require 'telescope'
      local actions = require 'telescope.actions'
      local action_state = require 'telescope.actions.state'

      opts = vim.tbl_deep_extend ('force', opts or {}, {
        defaults = {
          mappings = {
            i = vim.tbl_extend('force', defaults.keymaps(), {
              ["<c-f><c-p>"] = function(prompt_bufnr)
                local current_picker = action_state.get_current_picker(prompt_bufnr) -- picker state
                local entry = action_state.get_selected_entry()
                vim.print('Picker', current_picker)
                vim.print('Entry', entry)
              end,
              -- Lazy reload plugin
              ["<c-f><c-r>"] = function(prompt_bufnr)
                local current_picker = action_state.get_current_picker(prompt_bufnr) -- picker state
                local entry = action_state.get_selected_entry()
                local plugin_name = entry.name
                local plugin = require("lazy.core.config").plugins[plugin_name]
                require("lazy.core.loader").reload(plugin)
                vim.print('Reloaded '..plugin_name..'.')
              end,
              -- ["<esc>"] = actions.close,
            }),
            n = vim.tbl_extend('force', defaults.keymaps(), {
              ["<esc>"] = actions.close,
            }),
          },
        },

        extensions = {
          zoxide = {
            prompt_title = "[ Walking on the shoulders of TJ ]",
            mappings = {
              default = {
                after_action = function(selection)
                  print("Update to (" .. selection.z_score .. ") " .. selection.path)
                end
              },
              ["<C-f><C-f>"] = {
                before_action = function(selection) print("before C-f") end,
                action = function(selection)
                  vim.cmd.edit(selection.path)
                end
              },
              -- -- Opens the selected entry in a new split
              -- ["<C-q>"] = {
              --   action = z_utils.create_basic_command("split"),
              -- },
            },
          },
          bookmarks = { selected_browser = "firefox" },
        },
      })
      telescope.setup(opts)

      telescope.load_extension "manix"
      telescope.load_extension "undo"
      telescope.load_extension "cheat"
      telescope.load_extension "env"
      telescope.load_extension "file_browser"
      telescope.load_extension "live_grep_args"
      telescope.load_extension "lazy"
      telescope.load_extension "menufacture" -- better defaults
      -- telescope.load_extension "smart_history" -- better defaults

      -- Enable telescope fzf native, if installed
      pcall(telescope.load_extension, 'fzf')
    end,

    keys = {
      -- Nix
      -- map('n', '<leader>fn', function ()
      --   telescope_manix.search{ cword = true }
      -- end , { desc = 'Ma[n]ix Search for selected word' })
      -- map('n', '<leader>fN', function ()
      --   telescope_manix.search{ cword = false }
      -- end, { desc = '[N] Manix Search (global)' })

      -- Project
      -- -- vim.keymap.set('n', '<leader>fp', builtin.project, { desc = 'Search projects' })
    },
  },
}
-- requires nix plugin, sqlite.lua must be installed via nix
-- {
--   'prochri/telescope-all-recent.nvim',
--   dependencies = {
--     NixPlugin('kkharji/sqlite.lua'),
--   },
--   opts = {
--     database = {
--       folder = vim.fn.stdpath("data"),
--       file = "telescope-all-recent.sqlite3",
--       max_timestamps = 10,
--     },
--     scoring = {
--       recency_modifier = { -- also see telescope-frecency for these settings
--         [1] = { age = 240, value = 100 }, -- past 4 hours
--         [2] = { age = 1440, value = 80 }, -- past day
--         [3] = { age = 4320, value = 60 }, -- past 3 days
--         [4] = { age = 10080, value = 40 }, -- past week
--         [5] = { age = 43200, value = 20 }, -- past month
--         [6] = { age = 129600, value = 10 } -- past 90 days
--       },
--       -- how much the score of a recent item will be improved.
--       boost_factor = 0.0001
--     },
--     default = {
--       disable = true, -- disable any unkown pickers (recommended)
--       use_cwd = true, -- differentiate scoring for each picker based on cwd
--       sorting = 'recent' -- sorting: options: 'recent' and 'frecency'
--     },
--   },
-- },
