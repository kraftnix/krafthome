local snippets = {}

-- Found in https://github.com/L3MON4D3/LuaSnip/issues/1045
local M = {}
--- Return the comment box line considering the string `str`.
function M.comment_box_line(str)
  local cur_pos   = vim.api.nvim_win_get_cursor(0)
  local str_width = vim.fn.strdisplaywidth(str)
  local tw        = vim.o.textwidth

  local ind = vim.fn.indent(cur_pos[1])
  local cbw = tw - ind

  if ((cbw >= 0) and (str_width < cbw - 4)) then
    return string.rep("#", cbw)
  else
    return string.rep("#", str_width + 4)
  end
end

--- Return the left padding of the comment box text line considering the string `str`.
function M.comment_box_left_padding(str)
  local cur_pos   = vim.api.nvim_win_get_cursor(0)
  local str_width = vim.fn.strdisplaywidth(str)
  local tw        = vim.o.textwidth

  local ind = vim.fn.indent(cur_pos[1])
  local cbw = tw - ind

  if ((cbw >= 0) and (str_width < cbw - 4)) then
    local lpad = math.floor((cbw - 2 - str_width) / 2)
    local lstr = string.rep(" ", lpad)

    return "#" .. lstr
  else
    return "# "
  end
end

--- Return the right padding of the comment box text line considering the string `str`.
function M.comment_box_right_padding(str)
  local tw        = vim.o.textwidth
  local str_width = vim.fn.strdisplaywidth(str)
  local cur_pos   = vim.api.nvim_win_get_cursor(0)

  local ind = vim.fn.indent(cur_pos[1])
  local cbw = tw - ind

  if ((cbw >= 0) and (str_width < cbw - 4)) then
    local lpad = math.floor((cbw - 2 - str_width) / 2)
    local rpad = cbw - 2 - str_width - lpad

    local rstr = string.rep(" ", rpad)

    return rstr .. "#"
  else
    return " #"
  end
end


local comment_block = s({
  trig = "snip-command-block",
  dscr = "Julia Comment Block",
  docstring = {
    "###############################",
    "#            Comment          #",
    "###############################",
  },
}, {
    f(function (args)
      return M.comment_box_line(args[1][1])
    end, { 1 }),
    t({ "", ""}),
    f(function (args)
      return M.comment_box_left_padding(args[1][1])
    end, { 1 }),
    i(1, "Box"),
    f(function (args)
      return M.comment_box_right_padding(args[1][1])
    end, { 1 }),
    t({ "", ""}),
    f(function (args)
      return M.comment_box_line(args[1][1])
    end, { 1 }),
  })

table.insert(snippets, comment_block)

-- local pwd = s({
--   trig = "`pwd`";
-- }, {
--
-- })

return snippets
