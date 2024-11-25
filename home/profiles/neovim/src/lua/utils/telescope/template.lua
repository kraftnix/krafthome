pickers = require "telescope.pickers"
finders = require "telescope.finders"
actions = require "telescope.actions"
previewers = require 'telescope.previewers'
state = require 'telescope.actions.state'
conf = require("telescope.config").values

function containsUnderscoreAndNumber(string)
  local pattern = "%_[%d]+$" -- underscore followed by one or more digits at the end
  local match = string.match(string, pattern)
  return match ~= nil
end

function filter_dups(name)
  local pattern = ".+_[%d]+$" -- underscore followed by one or more digits at the end
  return not (string.match(name, pattern))
end

function readFlakeLock()
  local current_directory = vim.loop.cwd()
  local json_file = io.open(current_directory..'/flake.lock', 'r')
  local json_content = json_file:read('*all')
  json_file:close()

  local json_table = vim.fn.json_decode(json_content)
  local final_table = vim.iter(json_table.nodes):filter(filter_dups):totable()
  return final_table
end

vim.print(readFlakeLock())


function readNode(name, opts)
  return {
    name = name,
    locked = opts.locked,
    original = opts.original
  }
end

local flakeLock = readFlakeLock()
vim.print(readNode(flakeLock[1][1], flakeLock[1][2]))

telescopeFlake = function(opts)
  opts = opts or {}
  local flakeLock = readFlakeLock()
  local scriptsNames = {}
  -- vim.print(flakeLock)
  local inputs = vim.iter(flakeLock):map(readNode)
  local names = inputs:map(function (o)
    return o.name
  end):totable()
  vim.print(names)
  pickers.new(opts, {
    prompt_title = 'Scripts',
    previewer = previewers.vim_buffer_cat.new(opts),
    finder = finders.new_table {
      results = inputs,
      entry_maker = function(o)
        return {
          value = o.name,
          -- req
          ordinal = o.name,
          display = o.name,
          -- path = "",
          lnum = 0,
          bufnr = 0,
        }
      end,
    },
    -- -- sorter = sorters.get_generic_fuzzy_sorter(),
    -- attach_mappings = function(prompt_bufnr, map)
    --   local execute_script = function()
    --     local selection = state.get_selected_entry(prompt_bufnr)
    --     actions.close(prompt_bufnr)
    --     -- Terminal:new({ cmd = "' .. scriptsFromJson[selection.value] .. '", hidden = true }):toggle()
    --   end
    --
    --   map('i', '<CR>', execute_script)
    --   map('n', '<CR>', execute_script)
    --
    --   return true
    -- end
  }):find()
end
telescopeFlake({})

-- queries `terminal.lua` for current terminals
function test_finder ()
  local json_table = readFlakeLock()
  return require("telescope.finders").new_table({
    results = json_table,
    entry_maker = function(t)
      local prefix_text = tostring(t.index) .. ": "
      local full_text = prefix_text .. t.term.title
      local bufinfo = vim.fn.getbufinfo(t.term.bufnr)
      return {
        value = t,
        -- req
        ordinal = full_text,
        display = full_text,
        path = t.term.title,
        lnum = bufinfo.lnum,
        bufnr = bufinfo.bufnr,
      }
    end,
  })
end

function findAroundNote(opts)
  opts = opts or {}
  local pickers = require "telescope.pickers"
  local finders = require "telescope.finders"
  local actions = require "telescope.actions"
  local previewers = require 'telescope.previewers'
  vim.print('here')
  pickers.new(opts, {
    prompt_title = "Test",
    previewer = previewers.vim_buffer_cat.new(opts),
    finder = finders.new_oneshot_job({"rg", "--files", "-g", "20220221*", "--sort=path"}, opts),
    sorter = conf.generic_sorter(opts),
  }):find()
end
findAroundNote()

pickers.new({}, {
  prompt_title = "Select flake.nix",
  finder = test_finder(),
  attach_mappings = function(prompt_bufnr, _)
    -- modifying what happens on selection with <CR>
    actions.select_default:replace(function()
      -- closing picker
      actions.close(prompt_bufnr)
      -- the typically selection is table, depends on the entry maker
      -- here { [1] = "one", value = "one", ordinal = "one", display = "one" }
      -- value: original entry
      -- ordinal: for sorting, possibly transformed value
      -- display: for results list, possibly transformed value
      local selection = action_state.get_selected_entry()
      -- do stuff
    end)
    -- keep default keybindings
    return true
  end,
  sorter = conf.generic_sorter({}),
}):find()

pickers.new({}, {
  prompt_title = "Select cloned repo to remove",
  finder = finders.new_table {
    results = {"one", "two"}
  },
   attach_mappings = function(prompt_bufnr, _)
      -- modifying what happens on selection with <CR>
      actions.select_default:replace(function()
        -- closing picker
        actions.close(prompt_bufnr)
        -- the typically selection is table, depends on the entry maker
        -- here { [1] = "one", value = "one", ordinal = "one", display = "one" }
        -- value: original entry
        -- ordinal: for sorting, possibly transformed value
        -- display: for results list, possibly transformed value
        local selection = action_state.get_selected_entry()
        -- do stuff
      end)
      -- keep default keybindings
      return true
    end,
  sorter = conf.generic_sorter({}),
}):find()

--[[
--  Expect a list of KeyCommand
--  name (used as command name, no spaces)
--  description
--  mapping (used as mapping)
--  .. other shared opts
--]]
-- local live_grep_in = function(opts)
--   local p = opts[0]
--   require('telescope.builtin').live_grep({
--     path_display = 'smart',
--     search_dirs = vim.fn.expand(p)
--   })
-- end


-- require('telescope.builtin').live_grep({
--   cwd = vim.print("/")
-- })

-- require('telescope.builtin').find_files({
--   cwd = "~/.config/nvim",
--   search_dirs = { 'nix-plugins', 'lazy-plugins' },
--   follow = true
-- })

-- require('telescope.builtin').find_files({
--   cwd = "~/repos/NixOS/nixpkgs",
-- })

-- local live_grep_in = function(path, extra)
--   extra = extra or {}
--   return function ()
--     require('telescope.builtin').live_grep(vim.tbl_extend ('force', {
--       layout_strategy = 'vertical',
--       cwd = vim.fn.expand(path),
--       search_dirs = { vim.fn.expand(path) },
--     }, extra))
--   end
-- end



---- INFO: diagnostics
---- found in https://github.com/nvim-telescope/telescope.nvim/issues/701
local full_diagnostic_text = function()
    local action_state = require('telescope.actions.state')
    local selected_entry = action_state.get_selected_entry()
    local value = selected_entry['value']
    print(value.type .. ': ' .. value.text)
end

-- use quickfix window in combination with telescope
-- telescope: <C-q> sends items to quickfix list for later use
local toggle_qf = function()
  local windows = vim.fn.getwininfo()
  local qf_exists = false
  for _, win in pairs(windows) do
    if win['quickfix'] == 1 then qf_exists = true end
  end
  local qf_toggle = not qf_exists and 'cwindow' or 'cclose'
  vim.cmd(qf_toggle)
end
