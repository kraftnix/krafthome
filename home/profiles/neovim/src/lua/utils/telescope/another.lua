-- Something Went Wrong!"nui.menu")
local event = require("nui.utils.autocmd").event

local menu = Menu({
  position = "50%",
  size = {
    width = 25,
    height = 5,
  },
  border = {
    style = "single",
    text = {
      top = "[Choose-an-Element]",
      top_align = "center",
    },
  },
  win_options = {
    winhighlight = "Normal:Normal,FloatBorder:Normal",
  },
}, {
  lines = {
    Menu.item("Hydrogen (H)"),
    Menu.item("Carbon (C)"),
    Menu.item("Nitrogen (N)"),
    Menu.separator("Noble-Gases", {
      char = "-",
      text_align = "right",
    }),
    Menu.item("Helium (He)"),
    Menu.item("Neon (Ne)"),
    Menu.item("Argon (Ar)"),
  },
  max_width = 20,
  keymap = {
    focus_next = { "j", "<Down>", "<Tab>" },
    focus_prev = { "k", "<Up>", "<S-Tab>" },
    close = { "<Esc>", "<C-c>" },
    submit = { "<CR>", "<Space>" },
  },
  on_close = function()
    print("Menu Closed!")
  end,
  on_submit = function(item)
    print("Menu Submitted: ", item.text)
  end,
})

-- mount the component
menu:mount()

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

function readNode(name, opts)
  return {
    name = name,
    locked = opts.locked,
    original = opts.original
  }
end

local items = vim.iter(readFlakeLock()):map(readNode):totable()
vim.ui.select(items, {
	prompt = 'Inputs',
	format_item = function(input)
		return "I'd like to choose " .. input.name
	end,
}, function(choice)
		if choice == 'spaces' then
			vim.print('spaces')
		else
			vim.print('tabs')
		end
	end)

local Timer = Popup:extend("Timer")

function Timer:init(popup_options)
  local options = vim.tbl_deep_extend("force", popup_options or {}, {
    border = "double",
    focusable = false,
    position = { row = 0, col = "100%" },
    size = { width = 10, height = 1 },
    win_options = {
      winhighlight = "Normal:Normal,FloatBorder:SpecialChar",
    },
  })

  Timer.super.init(self, options)
end

function Timer:countdown(time, step, format)
  local function draw_content(text)
    local gap_width = 10 - vim.api.nvim_strwidth(text)
    vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, {
      string.format(
        "%s%s%s",
        string.rep(" ", math.floor(gap_width / 2)),
        text,
        string.rep(" ", math.ceil(gap_width / 2))
      ),
    })
  end

  self:mount()

  local remaining_time = time

  draw_content(format(remaining_time))

  vim.fn.timer_start(step, function()
    remaining_time = remaining_time - step

    draw_content(format(remaining_time))

    if remaining_time <= 0 then
      self:unmount()
    end
  end, { ["repeat"] = math.ceil(remaining_time / step) })
end

local timer = Timer()

timer:countdown(10000, 1000, function(time)
  return tostring(time / 1000) .. "s"
end)


local Menu = require("nui.menu")
local event = require("nui.utils.autocmd").event

local function override_ui_select()
  local UISelect = Menu:extend("UISelect")

  function UISelect:init(items, opts, on_done)
    local border_top_text = get_prompt_text(opts.prompt, "[Select Item]")
    local kind = opts.kind or "unknown"
    local format_item = opts.format_item or function(item)
      return tostring(item.__raw_item or item)
    end

    local popup_options = {
      relative = "editor",
      position = "50%",
      border = {
        style = "rounded",
        text = {
          top = border_top_text,
          top_align = "left",
        },
      },
      win_options = {
        winhighlight = "Normal:Normal,FloatBorder:Normal",
      },
      zindex = 999,
    }

    if kind == "codeaction" then
      -- change position for codeaction selection
      popup_options.relative = "cursor"
      popup_options.position = {
        row = 1,
        col = 0,
      }
    end

    local max_width = popup_options.relative == "editor" and vim.o.columns - 4 or vim.api.nvim_win_get_width(0) - 4
    local max_height = popup_options.relative == "editor" and math.floor(vim.o.lines * 80 / 100)
      or vim.api.nvim_win_get_height(0)

    local menu_items = {}
    for index, item in ipairs(items) do
      if type(item) ~= "table" then
        item = { __raw_item = item }
      end
      item.index = index
      local item_text = string.sub(format_item(item), 0, max_width)
      menu_items[index] = Menu.item(item_text, item)
    end

    local menu_options = {
      min_width = vim.api.nvim_strwidth(border_top_text),
      max_width = max_width,
      max_height = max_height,
      lines = menu_items,
      on_close = function()
        on_done(nil, nil)
      end,
      on_submit = function(item)
        on_done(item.__raw_item or item, item.index)
      end,
    }

    UISelect.super.init(self, popup_options, menu_options)

    -- cancel operation if cursor leaves select
    self:on(event.BufLeave, function()
      on_done(nil, nil)
    end, { once = true })
  end

  local select_ui = nil

  vim.ui.select = function(items, opts, on_choice)
    assert(type(on_choice) == "function", "missing on_choice function")

    if select_ui then
      -- ensure single ui.select operation
      vim.api.nvim_err_writeln("busy: another select is pending!")
      return
    end

    select_ui = UISelect(items, opts, function(item, index)
      if select_ui then
        -- if it's still mounted, unmount it
        select_ui:unmount()
      end
      -- pass the select value
      on_choice(item, index)
      -- indicate the operation is done
      select_ui = nil
    end)

    select_ui:mount()
  end
end
override_ui_select()

local Popup = require("nui.popup")

local popup = Popup({
  position = "50%",
  size = {
    width = 80,
    height = 40,
  },
  enter = true,
  focusable = true,
  zindex = 50,
  relative = "editor",
  border = {
    padding = {
      top = 2,
      bottom = 2,
      left = 3,
      right = 3,
    },
    style = "rounded",
    text = {
      top = " I am top title ",
      top_align = "center",
      bottom = "I am bottom title",
      bottom_align = "left",
    },
  },
  buf_options = {
    modifiable = true,
    readonly = false,
  },
  win_options = {
    winblend = 10,
    winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
  },
})
popup:mount()

local Menu = require("nui.menu")
local event = require("nui.utils.autocmd").event

local popup_options = {
  relative = "cursor",
  position = {
    row = 1,
    col = 0,
  },
  border = {
    style = "rounded",
    text = {
      top = "[Choose Item]",
      top_align = "center",
    },
  },
  win_options = {
    winhighlight = "Normal:Normal",
  }
}

local menu = Menu(popup_options, {
  lines = {
    Menu.separator("Group One"),
    Menu.item("Item 1"),
    Menu.item("Item 2"),
    Menu.separator("Group Two", {
      char = "-",
      text_align = "right",
    }),
    Menu.item("Item 3"),
    Menu.item("Item 4"),
  },
  max_width = 20,
  keymap = {
    focus_next = { "j", "<Down>", "<Tab>" },
    focus_prev = { "k", "<Up>", "<S-Tab>" },
    close = { "<Esc>", "<C-c>" },
    submit = { "<CR>", "<Space>" },
  },
  on_close = function()
    print("CLOSED")
  end,
  on_submit = function(item)
    print("SUBMITTED", vim.inspect(item))
  end,
})

local Layout = require("nui.layout")
local Popup = require("nui.popup")

local top_popup = Popup({ border = "double" })
local NuiText = require("nui.text")

local text = NuiText("Something Went Wrong!", "Error")

local bufnr, ns_id, linenr_start, byte_start = 0, -1, 1, 0

text:render(bufnr, ns_id, linenr_start, byte_start)

local layout = Layout(
  {
    position = "50%",
    size = {
      width = 80,
      height = 40,
    },
  },
  Layout.Box({
    Layout.Box(menu, {size = '50%' }),
    Layout.Box(text, { size = "50%" }),
  }, { dir = "col" })
)

layout:mount()

local Popup = require("nui.popup")
local Line = require("nui.line")
local Text = require("nui.text")
local Tree = require("nui.tree")
local event = require("nui.utils.autocmd").event

local function read_file(filename)
  local file, err = io.open(filename, "r")
  if not file then
    error(err)
  end
  local content = file:read("*a")
  io.close(file)
  return content
end

local function map(items, callback)
  local result = {}
  for i, item in ipairs(items) do
    result[i] = callback(item, i)
  end
  return result
end

local function for_each(items, callback)
  for i, item in ipairs(items) do
    callback(item, i)
  end
end

local mod = {}

local function list_query_sources(lang)
  local sources = {}
  local paths = vim.treesitter.get_query_files(lang, "*")

  local is_seen = {}

  for i, path in ipairs(paths) do
    if not is_seen[path] then
      is_seen[path] = true

      sources[i] = {
        lang = lang,
        filepath = path,
        plugin_name = vim.fn.fnamemodify(path, ":h:h:h:t"),
        query_name = vim.fn.fnamemodify(path, ":t:r"),
      }
    end
  end

  return sources
end

local function check_query_file_health(node)
  local query_content = read_file(node.filepath)

  local ok, err = pcall(vim.treesitter.query.parse_query, node.lang, query_content)

  if ok then
    node.ok = true
    node.err = nil
    node.err_position = nil
  else
    node.ok = false
    node.err = err
    node.err_position = string.match(node.err, "position (%d+)")
  end
end

local function get_query_source_nodes(langs)
  local nodes = {}

  for _, lang in ipairs(langs) do
    local query_sources = list_query_sources(lang)
    local children = map(query_sources, function(source)
      source.id = lang .. "-" .. source.filepath
      return Tree.Node(source)
    end)
    table.insert(nodes, Tree.Node({ text = lang }, children))
  end

  return nodes
end

function mod.open_treesitter_query_files_browser(...)
  local langs = { ... }

  if #langs == 0 then
    langs = require("nvim-treesitter.info").installed_parsers()
  end

  local popup = Popup({
    enter = true,
    position = "50%",
    size = {
      width = "80%",
      height = "60%",
    },
    border = {
      style = "rounded",
      text = {
        top = "Treesitter Query Files",
      },
    },
    buf_options = {
      readonly = true,
      modifiable = false,
    },
    win_options = {
      winhighlight = "Normal:Normal,FloatBorder:Normal",
    },
  })

  popup:mount()

  popup:on({ event.BufWinLeave }, function()
    vim.schedule(function()
      popup:unmount()
    end)
  end, { once = true })

  local tree = Tree({
    winid = popup.winid,
    nodes = get_query_source_nodes(langs),
    prepare_node = function(node)
      local line = Line()

      if node:has_children() then
        line:append(node:is_expanded() and " " or " ", "SpecialChar")
        line:append("Language: " .. node.text)

        return line
      end

      line:append("  [")
      if node.ok then
        line:append(Text("✓", "DiagnosticSignInfo"))
      elseif node.err then
        line:append(Text("×", "DiagnosticSignError"))
      else
        line:append(" ")
      end
      line:append("] ")

      line:append(node.plugin_name .. " ::: " .. node.query_name, {
        virt_text = { { " ::: " .. vim.fn.fnamemodify(node.filepath, ":~"), "Folded" } },
        virt_text_pos = "eol",
      })

      return line
    end,
  })

  local map_options = { remap = false, nowait = true }

  -- exit
  popup:map("n", { "q", "<esc>" }, function()
    popup:unmount()
  end, map_options)

  -- collapse
  popup:map("n", "h", function()
    local node, linenr = tree:get_node()
    if not node:has_children() then
      node, linenr = tree:get_node(node:get_parent_id())
    end
    if node and node:collapse() then
      vim.api.nvim_win_set_cursor(popup.winid, { linenr, 0 })
      tree:render()
    end
  end, map_options)

  -- expand
  popup:map("n", "l", function()
    local node, linenr = tree:get_node()
    if not node:has_children() then
      node, linenr = tree:get_node(node:get_parent_id())
    end
    if node and node:expand() then
      if not node.checked then
        node.checked = true

        vim.schedule(function()
          for _, n in ipairs(tree:get_nodes(node:get_id())) do
            check_query_file_health(n)
          end
          tree:render()
        end)
      end

      vim.api.nvim_win_set_cursor(popup.winid, { linenr, 0 })
      tree:render()
    end
  end, map_options)

  -- open
  popup:map("n", "o", function()
    local node = tree:get_node()
    if not node.filepath then
      return
    end

    vim.cmd(
      string.format(
        "tab drop %s | %s",
        node.filepath,
        node.err_position and string.gsub(string.format([[goto %s]], node.err_position), " ", " ") or ""
      )
    )
  end, map_options)

  -- refresh
  popup:map("n", "r", function()
    local node = tree:get_node()
    vim.schedule(function()
      if node:has_children() then
        for_each(tree:get_nodes(node:get_id()), check_query_file_health)
      else
        check_query_file_health(node)
      end

      tree:render()
    end)
  end, map_options)

  tree:render()
end

mod.open_treesitter_query_files_browser('json')

local Split = require("nui.split")
local split = Split({
  position = "bottom",
  size = 20,
})
local NuiTable = require("nui.table")
local tbl = NuiTable({
  -- bufnr = vim.fn.nvim_get_current_buf(),
  bufnr = split.bufnr,
  columns = {
    {
      align = "center",
      header = "Name",
      columns = {
        { accessor_key = "firstName", header = "First" },
        {
          id = "lastName",
          accessor_fn = function(row)
            return row.lastName
          end,
          header = "Last",
        },
      },
    },
    {
      align = "right",
      accessor_key = "age",
      cell = function(cell)
        return Text(tostring(cell.get_value()), "DiagnosticInfo")
      end,
      header = "Age",
    },
  },
  data = {
    { firstName = "John", lastName = "Doe", age = 42 },
    { firstName = "Jane", lastName = "Doe", age = 27 },
  },
})

split:mount()

tbl:render()

local Line = require("nui.line")
local Split = require("nui.split")
local Table = require("nui.table")
local Text = require("nui.text")

local split = Split({
  position = "bottom",
  size = 20,
})

local function cell_id(cell)
  return cell.column.id
end

local function capitalize(value)
  return (string.gsub(value, "^%l", string.upper))
end

local grouped_columns = {
  {
    align = "center",
    header = "Name",
    footer = cell_id,
    columns = {
      {
        accessor_key = "firstName",
        cell = function(cell)
          return Text(capitalize(cell.get_value()), "DiagnosticInfo")
        end,
        header = "First",
        footer = cell_id,
      },
      {
        id = "lastName",
        accessor_fn = function(row)
          return capitalize(row.lastName)
        end,
        header = "Last",
        footer = cell_id,
      },
    },
  },
  {
    align = "center",
    header = "Info",
    footer = cell_id,
    columns = {
      {
        align = "center",
        accessor_key = "age",
        cell = function(cell)
          return Line({ Text(tostring(cell.get_value()), "DiagnosticHint"), Text(" y/o") })
        end,
        header = "Age",
        footer = "age",
      },
      {
        align = "center",
        header = "More Info",
        footer = cell_id,
        columns = {
          {
            align = "right",
            accessor_key = "visits",
            header = "Visits",
            footer = cell_id,
          },
          {
            accessor_key = "status",
            header = "Status",
            footer = cell_id,
            max_width = 6,
          },
        },
      },
    },
  },
  {
    align = "right",
    header = "Progress",
    accessor_key = "progress",
    footer = cell_id,
  },
}

local table = Table({
  bufnr = split.bufnr,
  columns = grouped_columns,
  data = {
    {
      firstName = "tanner",
      lastName = "linsley",
      age = 24,
      visits = 100,
      status = "In Relationship",
      progress = 50,
    },
    {
      firstName = "tandy",
      lastName = "miller",
      age = 40,
      visits = 40,
      status = "Single",
      progress = 80,
    },
    {
      firstName = "joe",
      lastName = "dirte",
      age = 45,
      visits = 20,
      status = "Complicated",
      progress = 10,
    },
  },
})

table:render()

split:mount()

split:map("n", "q", function()
  split:unmount()
end, {})

split:map("n", "x", function()
  local cell = table:get_cell()
  if cell then
    local column = cell.column
    if column.accessor_key then
      cell.row.original[column.accessor_key] = "Poof!"
    end
    table:refresh_cell(cell)
  end
end, {})
