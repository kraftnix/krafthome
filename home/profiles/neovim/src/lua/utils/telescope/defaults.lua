local M = {}

-- vimgrep
M.vimgrep_core = {
  'rg',
  '--color=never',
  '--no-heading',
  '--with-filename',
  '--line-number',
  '--column',
  '--smart-case',
}

-- show all hidden
M.vimgrep_hidden = vim.tbl_flatten({
  M.vimgrep_core,
  {'--hidden'},
})

-- or filter out .gitignore but don't include .git
M.vimgrep_hidden_no_git = vim.tbl_flatten({
  M.vimgrep_core,
  {
    '--glob',
    '!**/.git/**',
    '--glob',
    '!**/.github/**',
    '--hidden',
    -- follow symlinks
    '-L',
  }
})

-- or filter out .gitignore but don't include .git and follow symlinks
M.vimgrep_hidden_no_git = vim.tbl_flatten({
  M.vimgrep_hidden_no_git,
  { '-L', }
})


----- Find Files ------

M.find_files = {
  hidden = true,
  follow = true,
  sort_mru = true,
  path_display = {
    -- smart = true, --remove as much from the path as possible
    -- shorten = 7,
  },
  find_command = {
    "fd",
    "--type", "file",
    "--hidden",
    -- "--strip-cwd-prefix"
  },
  file_ignore_patterns = { "^.git/", "^node_modules/" }
}

M.buffers = {
  -- sort_lastused = true, -- only sorts last used
  sort_mru = true, -- sorts all by last used
  path_display = {
    -- smart = true, --remove as much from the path as possible
    shorten = 7,
  },
  -- added to globals
  -- mappings = {
  --   i = {
  --     ['<C-b>d'] = actions.delete_buffer
  --   },
  --   n = {
  --     ['<C-b>d'] = actions.delete_buffer
  --   }
  -- }
}

M.keymaps = function ()
  local actions = require 'telescope.actions'
  local actions_generate = require 'telescope.actions.generate'
  local layout = require 'telescope.actions.layout'
  -- https://github.com/LazyVim/LazyVim/pull/1294
  -- local which_key = function(...)
  --   return require("telescope.actions.generate").which_key({
  --     name_width = 20, -- typically leads to smaller floats
  --     max_height = 0.5, -- increase potential maximum height
  --     separator = " ------> ", -- change sep between mode, keybind, and name
  --     close_with_action = false, -- do not close float on action
  --   })
  -- end
  return {
    ['<C-h>'] = actions.which_key,
    ['<C-f><c-space>'] = layout.toggle_preview,
    ['<C-f><c-l>'] = layout.cycle_layout_next,
    ['<C-f><c-d>'] = actions.delete_buffer,
    ["<C-j>"] = actions.move_selection_next,
    ["<C-k>"] = actions.move_selection_previous,
    ["<CR>"] = actions.select_default + actions.center,
    ["<C-x>"] = actions.select_horizontal,
    ["<C-c>"] = actions.close,
    -- ["<esc>"] = actions.close,
    ["<C-n>"] = actions.cycle_history_next,
    ["<C-p>"] = actions.cycle_history_prev,
    ["<C-o>"] = actions.results_scrolling_up,
    ["<C-e>"] = actions.results_scrolling_down,
    ["<C-z>"] = actions.complete_tag,
    -- ["<C-?>"] = which_key(),
  }
end



return M
