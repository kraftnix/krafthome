-- The filled in variant of the < symbol
local SOLID_LEFT_ARROW = utf8.char(0xe0b2)

-- The filled in variant of the > symbol
local SOLID_RIGHT_ARROW = utf8.char(0xe0b0)

function scandir(directory)
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('ls -a "'..directory..'"')
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename
    end
    pfile:close()
    return t
end

function basename(s)
  return string.gsub(s, "(.*[/\\])(.*)", "%2")
end

-- Format tab title
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  --local edge_background = "#0b0022"
  local edge_background = background
  local edge_foreground = foreground
  --local background = "#1b1032"
  --local foreground = "#808080"
  --background = backgroundAlt
  local currBackground = background
  local currForeground = foreground
  if tab.is_active then
    --background = "#2b2042"
    --foreground = "#c0c0c0"
    currBackground = primary
    currForeground = background
    edge_foreground = secondary
  end
  if tab.active_pane.is_zoomed then
    currForeground = orange
  end
  local has_unseen_output = false
  for _, pane in ipairs(tab.panes) do
    if pane.has_unseen_output then
      has_unseen_output = true
      break;
    end
  end
  if has_unseen_output then
    currForeground = green
  end

  -- ensure that the titles fit in the available space,
  -- and that we have room for the edges.
  local program = tab.active_pane.foreground_process_name;
  local programStr = {}
  local cprogram = ""
  -- get last string of longform pane title
  for word in tab.active_pane.title:gmatch("%S+") do table.insert(programStr, word) end
  if (programStr ~= nil) and (programStr ~= "") and (#programStr > 0) then
    cprogram = programStr[#programStr]
  end
  -- choose shortened longform if program is not defined
  if cprogram ~= nil or cprogram ~= "" then
    program = cprogram
  end
  local path = basename(tab.active_pane.current_working_dir)
  local index = tostring(tab.tab_index + 1)
  local title = " " .. index .. ": " .. program .. " - " .. path .. " "

  -- Lua implementation of PHP scandir function

  return {
    {Background={Color=edge_background}},
    {Foreground={Color=edge_foreground}},
    {Text=SOLID_LEFT_ARROW},
    {Background={Color=currBackground}},
    {Foreground={Color=currForeground}},
    {Text=title},
    {Background={Color=edge_background}},
    {Foreground={Color=edge_foreground}},
    {Text=SOLID_RIGHT_ARROW},
  }
end)


--wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
--  if tab.is_active then
--    return {
--      {Background={Color="purple"}},
--      {Text=" " .. tab.active_pane.title .. " "},
--    }
--  end
--  local has_unseen_output = false
--  for _, pane in ipairs(tab.panes) do
--    if pane.has_unseen_output then
--      has_unseen_output = true
--      break;
--    end
--  end
--  if has_unseen_output then
--    return {
--      {Text=" " .. tab.active_pane.title .. " "},
--    }
--  end
--  return tab.active_pane.title
--end)
