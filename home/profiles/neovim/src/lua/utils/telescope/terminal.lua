---@enum term_actions
local TERM_ACTIONS = {
  open = 'open',
  target = 'target',
  kill = 'kill',
  force_kill = 'force_kill',
}

-- handles `terminal.lua` action
---@param bufnr integer
---@param action_type term_actions
---@return function
local function handle_term(bufnr, action_type)
  local actions = require "telescope.actions"
  local action_state = require "telescope.actions.state"
  return function()
    actions.close(bufnr)
    local selection = action_state.get_selected_entry()
    local terminal = selection.value
    if type(terminal) ~= 'table' then return end

    local t = require('terminal')
    if action_type == TERM_ACTIONS.open then
      print(vim.inspect(terminal))
      t.set_target(terminal.index)
      t.open(terminal.index)
    elseif action_type == TERM_ACTIONS.target then
      t.set_target(terminal.index)
    elseif action_type == TERM_ACTIONS.force_kill then
      t.kill(terminal.index, true)
    elseif action_type == TERM_ACTIONS.kill then
      local reply = vim.fn.input('Really kill? (y/n):')
      if reply == 'y' then
        t.kill(terminal.index)
      else
        vim.notify('Terminal kill cancelled','info')
      end
    else
      print('Unsupported action type: ' .. action_type)
    end
  end
end

-- queries `terminal.lua` for current terminals
local function telescope_terminals_finder ()
  return require("telescope.finders").new_table({
    results = require('terminal').get_terminal_ids(),
    entry_maker = function(chunk)
      local prefix_text = tostring(chunk.index) .. ": "
      local full_text = prefix_text .. chunk.term.title
      local bufinfo = vim.fn.getbufinfo(chunk.term.bufnr)
      -- NOTE: wip showlast cursor position in preview
      -- vim.print('bufnr: '..chunk.term.bufnr)
      -- vim.print('bufinfo: ', bufinfo)
      -- vim.print('bufwinid: '.. vim.fn.bufwinid(chunk.term.bufnr))
      -- -- local final_lnum  vim.fn.line('.', vim.fn.bufwinid(chunk.term.bufnr))
      -- local final_lnum = bufinfo.linecount
      -- -- vim.print(vim.fn.getjumplist())
      -- vim.print(final_lnum)
      return {
        value = chunk,
        -- req
        ordinal = full_text,
        display = full_text,
        path = chunk.term.title,
        -- lnum = bufinfo.lnum,
        lnum = final_lnum,
        bufnr = chunk.term.bufnr,
      }
    end,
  })
end

local function previewer(entry, bufnr)
  vim.print(entry)
  if entry.readme then
    local readme = vim.fn.readfile(entry.readme)
    -- vim.api.nvim_buf_set_option(bufnr, "filetype", "markdown")
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, readme)
  end
end

local function telescope_terminals_picker(opts)
  opts = opts or require("telescope.themes").get_dropdown()
  require("telescope.pickers").new(opts, {
    prompt_title = "Terminals",
    finder = telescope_terminals_finder(),
    -- previewer = require('telescope.config').values.grep_previewer(vim.tbl_deep_extend('force', opts, {
    --   -- preview_command = previewer,
    -- })),
    previewer = require('telescope.config').values.grep_previewer(vim.tbl_deep_extend('force', opts, {
      -- preview_command = previewer,
    })),
    -- previewer = require('telescope.previewers').(vim.tbl_deep_extend('force', opts, {
    --   -- preview_command = previewer,
    -- })),
    sorter = require("telescope.config").values.generic_sorter(opts),
    attach_mappings = function(bufnr, map)
      -- map("i", "<c-f><c-d>", handle_term(bufnr, 'kill'))
      -- map("n", "<c-f><c-d>", handle_term(bufnr, 'kill'))
      map("i", "<c-f><c-k>", handle_term(bufnr, 'force_kill'))
      map("n", "<c-f><c-k>", handle_term(bufnr, 'force_kill'))
      map("i", "<CR>", handle_term(bufnr, 'open'))
      map("n", "<CR>", handle_term(bufnr, 'open'))
      map("n", "<c-g>", handle_term(bufnr, 'target'))
      map("i", "<c-g>", handle_term(bufnr, 'target'))
      return true
    end,
  }):find()
end

local function test_picker(opts)
  opts = opts or require("telescope.themes").get_dropdown()
  return require("telescope.pickers").new(opts, {
    prompt_title = "Terminals",
    finder = require('telescope.builtin').find_files({

    }),
    -- finder = telescope_terminals_finder(),
    previewer = require('telescope.config').values.grep_previewer(opts),
    sorter = require("telescope.config").values.generic_sorter(opts),
    attach_mappings = function(bufnr, map)
      map("i", "<CR>", handle_term(bufnr, 'open'))
      map("n", "<CR>", handle_term(bufnr, 'open'))
      map("n", "<c-g>", handle_term(bufnr, 'target'))
      map("i", "<c-g>", handle_term(bufnr, 'target'))
      return true
    end,
  }):find()
end

return {
  telescope_terminals = telescope_terminals_picker,
}
