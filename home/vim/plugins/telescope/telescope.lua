local actions = require('telescope.actions')
local pickers = require'telescope.pickers'
local sorters = require'telescope.sorters'
local finders = require'telescope.finders'
local previewers = require'telescope.previewers'
local from_entry = require'telescope.from_entry'
local actions_set = require'telescope.actions.set'
local utils = require'telescope.utils'
local putils = require('telescope.previewers.utils')
local action_set = require('telescope.actions.set')

local function action_edit_ctrl_l(prompt_bufnr)
    return action_set.select(prompt_bufnr, "ctrl-l")
end

local function action_edit_ctrl_r(prompt_bufnr)
    return action_set.select(prompt_bufnr, "ctrl-r")
end

require('telescope').setup {
  defaults = {
      layout_config = {
          prompt_position = "bottom",
          vertical = { width = 0.97, height = 0.99 }
      },
      sorting_strategy = "descending",
      layout_strategy = 'vertical',
      mappings = {
          i = {
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            ["<CR>"] = actions.select_default + actions.center,
            ["<C-s>"] = actions.select_horizontal,
            ["<esc>"] = actions.close,
            ["<C-l>"] = action_edit_ctrl_l,
            ["<C-r>"] = action_edit_ctrl_r,
            ["<C-n>"] = actions.cycle_history_next,
            ["<C-p>"] = actions.cycle_history_prev,
            ["<C-o>"] = actions.results_scrolling_up,
            ["<C-e>"] = actions.results_scrolling_down,
            ["<C-z>"] = actions.complete_tag,
          },
          n = {
              ["<esc>"] = actions.close,
          },
      },
  },
  pickers = {
      buffers = {
          ignore_current_buffer = true,
          sort_mru = true,
      },
      find_files = {
          additional_args = function(opts)
              return {"hidden=true"}
          end
      },
      live_grep = {
          additional_args = function(opts)
              return {"--hidden"}
          end
      },
  },
  extensions = {
    undo = {
      side_by_side = false,
    },
    file_browser = {
      theme = "ivy",
      -- disables netrw and use telescope-file-browser in its place
      hijack_netrw = true,
      mappings = {
        ["i"] = {
          -- your custom insert mode mappings
        },
        ["n"] = {
          -- your custom normal mode mappings
        },
      },
    },
    fzf = {
        fuzzy = true,                    -- false will only do exact matching
        override_generic_sorter = false, -- override the generic sorter
        override_file_sorter = true,     -- override the file sorter
        case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
    },
  }
}

require("telescope").load_extension "manix"
require("telescope").load_extension "undo"
require("telescope").load_extension "cheat"
require('telescope').load_extension "env"
require("telescope").load_extension "file_browser"
require('telescope').load_extension "fzf"

--require('telescope').load_extension('gh')
--require('telescope').load_extension('dap')
--require('telescope').load_extension('project')
--
require("telescope-tabs").setup {}

vim.api.nvim_set_keymap(
  "n",
  "<leader>tb",
  ":Telescope file_browser<CR>",
  { noremap = true }
)

-- Custom pickers
local cdPicker = function(name, cmd)
    pickers.new({}, {
        prompt_title = name,
        finder = finders.new_table{ results = utils.get_os_command_output(cmd) },
        previewer = previewers.vim_buffer_cat.new({}),
        sorter = sorters.get_fuzzy_file(),
        attach_mappings = function(prompt_bufnr)
            actions_set.select:replace(function(_, type)
                local entry = actions.get_selected_entry()
                actions.close(prompt_bufnr)
                local dir = from_entry.path(entry)
                vim.cmd('cd '..dir)
            end)
            return true
        end,
    }):find()
end

function Cd(path)
    path = path or '.'
    cdPicker('Cd', {vim.o.shell, '-c', "fd . "..path.." --type=d 2>/dev/null"})
end

function Cdz()
    cdPicker('z directories', {vim.o.shell, '-c', "cat ~/.z | cut -d '|' -f1"})
end

function File_picker()
    vim.fn.system('git rev-parse --git-dir > /dev/null 2>&1')
    local is_git = vim.v.shell_error == 0
    if is_git then
        require'telescope.builtin'.find_files()
    else
        vim.cmd 'Files'
    end
end

require'telescope-all-recent'.setup{
  database = {
    folder = vim.fn.stdpath("data"),
    file = "telescope-all-recent.sqlite3",
    max_timestamps = 10,
  },
  scoring = {
    recency_modifier = { -- also see telescope-frecency for these settings
      [1] = { age = 240, value = 100 }, -- past 4 hours
      [2] = { age = 1440, value = 80 }, -- past day
      [3] = { age = 4320, value = 60 }, -- past 3 days
      [4] = { age = 10080, value = 40 }, -- past week
      [5] = { age = 43200, value = 20 }, -- past month
      [6] = { age = 129600, value = 10 } -- past 90 days
    },
    -- how much the score of a recent item will be improved.
    boost_factor = 0.0001
  },
  default = {
    disable = true, -- disable any unkown pickers (recommended)
    use_cwd = true, -- differentiate scoring for each picker based on cwd
    sorting = 'recent' -- sorting: options: 'recent' and 'frecency'
  },
}
