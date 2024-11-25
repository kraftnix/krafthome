-- copied from zephyr.nvim
local b = {
  base00 = "#1a1b26"; -- background
  base01 = "#32344a"; -- lighter background
  base02 = "#449dab"; -- Selection
  base03 = "#787c99"; -- Comments
  base04 = "#acb0d0"; -- Dark Foreground
  base05 = "#a9b1d6"; -- Foreground
  base06 = "#7aa2f7"; -- Light Foreground
  base07 = "#ad8ee6"; -- Light Background
  base08 = "#ff7a93", -- red
  base09 = "#ff9e64", -- orange
  base0A = "#e0af68", -- yellow
  base0B = "#9ece6a", -- green
  base0C = "#449dab", -- cyan (normal)
  base0D = "#ad8ee6", -- magenta
  base0E = "#7aa2f7", -- blue
  base0F = "#0db9d7", -- cyan
}

local colour = {
  base0 = b.base00,
  base1 = b.base01,
  base2 = b.base02,
  base3 = b.base03,
  base4 = b.base04,
  base5 = b.base05,
  base6 = b.base07,
  base7 = b.base08,

  bg = b.base00,
  bg1 = b.base01,
  bg_popup = b.base03,
  bg_highlight = b.base03,
  bg_visual = b.base07,

  fg = b.base05,--done
  fg_alt = b.base06,


  red = b.base08,
  redwine = "#d16d9e",
  orange = b.base09,
  yellow = b.base0A,
  lignt_orange = "#fab795",
  green = b.base0B,
  -- #a8eb44
  dark_green = "#99ac65",
  cyan = b.base0F,
  blue = b.base0E,
  violet = b.base0D,
  magenta = "#c678dd",
  teal = b.base0C,
  grey = "#928374",
  brown = "#c78665",
  black = "#000000",

  bracket = b.base06,
  none = "NONE",
}

function colour.terminal_color()
  vim.g.terminal_color_0 = colour.bg
  vim.g.terminal_color_1 = colour.red
  vim.g.terminal_color_2 = colour.green
  vim.g.terminal_color_3 = colour.yellow
  vim.g.terminal_color_4 = colour.blue
  vim.g.terminal_color_5 = colour.violet
  vim.g.terminal_color_6 = colour.cyan
  vim.g.terminal_color_7 = colour.bg1
  vim.g.terminal_color_8 = colour.brown
  vim.g.terminal_color_9 = colour.red
  vim.g.terminal_color_10 = colour.green
  vim.g.terminal_color_11 = colour.yellow
  vim.g.terminal_color_12 = colour.blue
  vim.g.terminal_color_13 = colour.violet
  vim.g.terminal_color_14 = colour.cyan
  vim.g.terminal_color_15 = colour.fg
end

local syntax = {
  Normal = { fg = colour.fg, bg = colour.bg },
  Terminal = { fg = colour.fg, bg = colour.bg },
  SignColumn = { fg = colour.fg, bg = colour.bg },
  FoldColumn = { fg = colour.fg_alt, bg = colour.black },
  VertSplit = { fg = colour.black, bg = colour.bg },
  Folded = { fg = colour.lignt_orange, bg = colour.bg_highlight },
  EndOfBuffer = { fg = colour.bg, bg = colour.none },
  IncSearch = { fg = colour.bg1, bg = colour.orange },
  Search = { fg = colour.bg, bg = colour.orange },
  ColorColumn = { bg = colour.bg_highlight },
  Conceal = { fg = colour.green, bg = colour.none },
  Cursor = { bg = colour.none, reverse = true },
  vCursor = { bg = colour.none, reverse = true },
  iCursor = { bg = colour.none, reverse = true },
  lCursor = { bg = colour.none, reverse = true },
  CursorIM = { bg = colour.none, reverse = true },
  CursorColumn = { bg = colour.bg_highlight },
  CursorLine = { bg = colour.bg_highlight },
  LineNr = { fg = colour.base4 },
  qfLineNr = { fg = colour.cyan },
  CursorLineNr = { fg = colour.blue },
  DiffAdd = { fg = colour.black, bg = colour.dark_green },
  DiffChange = { fg = colour.black, bg = colour.yellow },
  DiffDelete = { fg = colour.black, bg = colour.red },
  DiffText = { fg = colour.black, bg = colour.fg },
  Directory = { fg = colour.blue, bg = colour.none },
  ErrorMsg = { fg = colour.red, bg = colour.none, bold = true },
  WarningMsg = { fg = colour.yellow, bg = colour.none, bold = true },
  ModeMsg = { fg = colour.fg, bg = colour.none, bold = true },
  MatchParen = { fg = colour.red, bg = colour.none },
  NonText = { fg = colour.bg1 },
  Whitespace = { fg = colour.base4 },
  SpecialKey = { fg = colour.bg1 },
  Pmenu = { fg = colour.fg, bg = colour.bg_popup },
  PmenuSel = { fg = colour.base0, bg = colour.blue },
  PmenuSelBold = { fg = colour.base0, bg = colour.blue },
  PmenuSbar = { bg = colour.base4 },
  PmenuThumb = { fg = colour.violet, bg = colour.light_green },
  WildMenu = { fg = colour.bg1, bg = colour.green },
  StatusLine = { fg = colour.base8, bg = colour.base2 },
  StatusLineNC = { fg = colour.grey, bg = colour.base2 },
  Question = { fg = colour.yellow },
  NormalFloat = { fg = colour.base8, bg = colour.bg_highlight },
  Tabline = { fg = colour.base6, bg = colour.base2 },
  TabLineSel = { fg = colour.fg, bg = colour.blue },
  SpellBad = { fg = colour.red, bg = colour.none, undercurl = true },
  SpellCap = { fg = colour.blue, bg = colour.none, undercurl = true },
  SpellLocal = { fg = colour.cyan, bg = colour.none, undercurl = true },
  SpellRare = { fg = colour.violet, bg = colour.none, undercurl = true },
  Visual = { fg = colour.black, bg = colour.bg_visual },
  VisualNOS = { fg = colour.black, bg = colour.bg_visual },
  QuickFixLine = { fg = colour.violet, bold = true },
  Debug = { fg = colour.orange },
  debugBreakpoint = { fg = colour.bg, bg = colour.red },

  Boolean = { fg = colour.orange },
  Number = { fg = colour.brown },
  Float = { fg = colour.brown },
  PreProc = { fg = colour.violet },
  PreCondit = { fg = colour.violet },
  Include = { fg = colour.violet },
  Define = { fg = colour.violet },
  Conditional = { fg = colour.magenta },
  Repeat = { fg = colour.magenta },
  Keyword = { fg = colour.green },
  Typedef = { fg = colour.red },
  Exception = { fg = colour.red },
  Statement = { fg = colour.red },
  Error = { fg = colour.red },
  StorageClass = { fg = colour.orange },
  Tag = { fg = colour.orange },
  Label = { fg = colour.orange },
  Structure = { fg = colour.orange },
  Operator = { fg = colour.redwine },
  Title = { fg = colour.orange, bold = true },
  Special = { fg = colour.yellow },
  SpecialChar = { fg = colour.yellow },
  Type = { fg = colour.teal },
  Function = { fg = colour.yellow },
  String = { fg = colour.lignt_orange },
  Character = { fg = colour.green },
  Constant = { fg = colour.cyan },
  Macro = { fg = colour.cyan },
  Identifier = { fg = colour.blue },

  Comment = { fg = colour.base6, italic = true },
  SpecialComment = { fg = colour.grey },
  Todo = { fg = colour.violet },
  Delimiter = { fg = colour.fg },
  Ignore = { fg = colour.grey },
  Underlined = { underline = true },

  DashboardShortCut = { fg = colour.magenta },
  DashboardHeader = { fg = colour.orange },
  DashboardCenter = { fg = colour.teal },
  DashboardCenterIcon = { fg = colour.blue },
  DashboardFooter = { fg = colour.yellow, bold = true },
}

local plugin_syntax = {
  ["@function"] = { fg = colour.cyan },
  ["@method"] = { fg = colour.cyan },
  ["@keyword.function"] = { fg = colour.red },
  ["@property"] = { fg = colour.yellow },
  ["@type"] = { fg = colour.teal },
  ["@variable"] = { fg = "#f2f2bf" },
  ["@punctuation.bracket"] = { fg = colour.bracket },

  vimCommentTitle = { fg = colour.grey, bold = true },
  vimLet = { fg = colour.orange },
  vimVar = { fg = colour.cyan },
  vimFunction = { fg = colour.redwine },
  vimIsCommand = { fg = colour.fg },
  vimCommand = { fg = colour.blue },
  vimNotFunc = { fg = colour.violet, bold = true },
  vimUserFunc = { fg = colour.yellow, bold = true },
  vimFuncName = { fg = colour.yellow, bold = true },

  diffAdded = { fg = colour.dark_green },
  diffRemoved = { fg = colour.red },
  diffChanged = { fg = colour.blue },
  diffOldFile = { fg = colour.yellow },
  diffNewFile = { fg = colour.orange },
  diffFile = { fg = colour.cyan },
  diffLine = { fg = colour.grey },
  diffIndexLine = { fg = colour.violet },

  gitcommitSummary = { fg = colour.red },
  gitcommitUntracked = { fg = colour.grey },
  gitcommitDiscarded = { fg = colour.grey },
  gitcommitSelected = { fg = colour.grey },
  gitcommitUnmerged = { fg = colour.grey },
  gitcommitOnBranch = { fg = colour.grey },
  gitcommitArrow = { fg = colour.grey },
  gitcommitFile = { fg = colour.dark_green },

  VistaBracket = { fg = colour.grey },
  VistaChildrenNr = { fg = colour.orange },
  VistaKind = { fg = colour.violet },
  VistaScope = { fg = colour.red },
  VistaScopeKind = { fg = colour.blue },
  VistaTag = { fg = colour.magenta, bold = true },
  VistaPrefix = { fg = colour.grey },
  VistaColon = { fg = colour.magenta },
  VistaIcon = { fg = colour.yellow },
  VistaLineNr = { fg = colour.fg },

  GitGutterAdd = { fg = colour.dark_green },
  GitGutterChange = { fg = colour.blue },
  GitGutterDelete = { fg = colour.red },
  GitGutterChangeDelete = { fg = colour.violet },

  GitSignsAdd = { fg = colour.dark_green },
  GitSignsChange = { fg = colour.blue },
  GitSignsDelete = { fg = colour.red },
  GitSignsAddNr = { fg = colour.dark_green },
  GitSignsChangeNr = { fg = colour.blue },
  GitSignsDeleteNr = { fg = colour.red },
  GitSignsAddLn = { bg = colour.bg_popup },
  GitSignsChangeLn = { bg = colour.bg_highlight },
  GitSignsDeleteLn = { bg = colour.bg1 },

  SignifySignAdd = { fg = colour.dark_green },
  SignifySignChange = { fg = colour.blue },
  SignifySignDelete = { fg = colour.red },

  dbui_tables = { fg = colour.blue },

  CursorWord = { bg = colour.base4, underline = true },

  NvimTreeFolderName = { fg = colour.blue },
  NvimTreeRootFolder = { fg = colour.red, bold = true },
  NvimTreeSpecialFile = { fg = colour.fg, bg = colour.none },
  NvimTreeGitDirty = { fg = colour.redwine },

  TelescopeBorder = { fg = colour.teal },
  TelescopePromptBorder = { fg = colour.blue },
  TelescopeMatching = { fg = colour.teal },
  TelescopeSelection = { fg = colour.yellow, bg = colour.bg_highlight, bold = true },
  TelescopeSelectionCaret = { fg = colour.yellow },
  TelescopeMultiSelection = { fg = colour.teal },

  -- nvim v0.6.0+
  DiagnosticSignError = { fg = colour.red },
  DiagnosticSignWarn = { fg = colour.yellow },
  DiagnosticSignInfo = { fg = colour.blue },
  DiagnosticSignHint = { fg = colour.cyan },

  DiagnosticError = { fg = colour.red },
  DiagnosticWarn = { fg = colour.yellow },
  DiagnosticInfo = { fg = colour.blue },
  DiagnosticHint = { fg = colour.cyan },

  LspReferenceRead = { bg = colour.bg_highlight, bold = true },
  LspReferenceText = { bg = colour.bg_highlight, bold = true },
  LspReferenceWrite = { bg = colour.bg_highlight, bold = true },

  DiagnosticVirtualTextError = { fg = colour.red },
  DiagnosticVirtualTextWarn = { fg = colour.yellow },
  DiagnosticVirtualTextInfo = { fg = colour.blue },
  DiagnosticVirtualTextHint = { fg = colour.cyan },

  DiagnosticUnderlineError = { undercurl = true, sp = colour.red },
  DiagnosticUnderlineWarn = { undercurl = true, sp = colour.yellow },
  DiagnosticUnderlineInfo = { undercurl = true, sp = colour.blue },
  DiagnosticUnderlineHint = { undercurl = true, sp = colour.cyan },

  -- Neogit
  NeogitDiffAddHighlight = { fg = colour.green },
  NeogitDiffDeleteHighlight = { fg = colour.red },
  NeogitDiffContextHighlight = { fg = colour.blue },
  NeogitHunkHeader = { fg = colour.fg },
  NeogitHunkHeaderHighlight = { fg = colour.redwine },

  -- nvim-cmp
  --
  --from zephyr
  -- CmpItemAbbr = { fg = colour.fg },
  -- CmpItemAbbrMatch = { fg = "#A6E22E" },
  -- CmpItemMenu = { fg = colour.violet },
  -- CmpItemKindVariable = { fg = colour.blue },
  -- CmpItemKindFiled = { fg = colour.magenta },
  -- CmpItemKindFunction = { fg = colour.yellow },
  -- CmpItemKindClass = { fg = colour.orange },
  -- CmpItemKindMethod = { fg = colour.teal },
  -- CmpItemKindKeyWord = { fg = colour.red },
  -- CmpItemKindText = { fg = colour.light_green },
  -- CmpItemKindModule = { fg = colour.cyan },

  PmenuSel = { bg = "NONE", fg = "#C5CDD9" },
  Pmenu = { fg = "#C5CDD9", bg = "NONE" },

  CmpItemAbbrDeprecated = { fg = "#7E8294", bg = "NONE", strikethrough = true },
  CmpItemAbbrMatch = { fg = "#82AAFF", bg = "NONE", bold = true },
  CmpItemAbbrMatchFuzzy = { fg = "#82AAFF", bg = "NONE", bold = true },
  CmpItemMenu = { fg = "#C792EA", bg = "NONE", italic = true },

  CmpItemKindField = { fg = "#EED8DA", bg = "#B5585F" },
  CmpItemKindProperty = { fg = "#EED8DA", bg = "#B5585F" },
  CmpItemKindEvent = { fg = "#EED8DA", bg = "#B5585F" },

  CmpItemKindText = { fg = "#C3E88D", bg = "#9FBD73" },
  CmpItemKindEnum = { fg = "#C3E88D", bg = "#9FBD73" },
  CmpItemKindKeyword = { fg = "#C3E88D", bg = "#9FBD73" },

  CmpItemKindConstant = { fg = "#FFE082", bg = "#D4BB6C" },
  CmpItemKindConstructor = { fg = "#FFE082", bg = "#D4BB6C" },
  CmpItemKindReference = { fg = "#FFE082", bg = "#D4BB6C" },

  CmpItemKindFunction = { fg = "#EADFF0", bg = "#A377BF" },
  CmpItemKindStruct = { fg = "#EADFF0", bg = "#A377BF" },
  CmpItemKindClass = { fg = "#EADFF0", bg = "#A377BF" },
  CmpItemKindModule = { fg = "#EADFF0", bg = "#A377BF" },
  CmpItemKindOperator = { fg = "#EADFF0", bg = "#A377BF" },

  CmpItemKindVariable = { fg = "#C5CDD9", bg = "#7E8294" },
  CmpItemKindFile = { fg = "#C5CDD9", bg = "#7E8294" },

  CmpItemKindUnit = { fg = "#F5EBD9", bg = "#D4A959" },
  CmpItemKindSnippet = { fg = "#F5EBD9", bg = "#D4A959" },
  CmpItemKindFolder = { fg = "#F5EBD9", bg = "#D4A959" },

  CmpItemKindMethod = { fg = "#DDE5F5", bg = "#6C8ED4" },
  CmpItemKindValue = { fg = "#DDE5F5", bg = "#6C8ED4" },
  CmpItemKindEnumMember = { fg = "#DDE5F5", bg = "#6C8ED4" },

  CmpItemKindInterface = { fg = "#D8EEEB", bg = "#58B5A8" },
  CmpItemKindColor = { fg = "#D8EEEB", bg = "#58B5A8" },
  CmpItemKindTypeParameter = { fg = "#D8EEEB", bg = "#58B5A8" },
}

-- cmp highlights
-- Highlight per type (hardcoded)
-- gray
-- vim.api.nvim_set_hl(0, 'CmpItemAbbrDeprecated', { bg='NONE', strikethrough=true, fg='#808080' })
-- -- blue
-- vim.api.nvim_set_hl(0, 'CmpItemAbbrMatch', { bg='NONE', fg='#569CD6' })
-- vim.api.nvim_set_hl(0, 'CmpItemAbbrMatchFuzzy', { link='CmpIntemAbbrMatch' })
-- -- light blue
-- vim.api.nvim_set_hl(0, 'CmpItemKindVariable', { bg='NONE', fg='#9CDCFE' })
-- vim.api.nvim_set_hl(0, 'CmpItemKindInterface', { link='CmpItemKindVariable' })
-- vim.api.nvim_set_hl(0, 'CmpItemKindText', { link='CmpItemKindVariable' })
-- -- pink
-- vim.api.nvim_set_hl(0, 'CmpItemKindFunction', { bg='NONE', fg='#C586C0' })
-- vim.api.nvim_set_hl(0, 'CmpItemKindMethod', { link='CmpItemKindFunction' })
-- -- front
-- vim.api.nvim_set_hl(0, 'CmpItemKindKeyword', { bg='NONE', fg='#D4D4D4' })
-- vim.api.nvim_set_hl(0, 'CmpItemKindProperty', { link='CmpItemKindKeyword' })
-- vim.api.nvim_set_hl(0, 'CmpItemKindUnit', { link='CmpItemKindKeyword' })

-- -- Customization for Pmenu
vim.api.nvim_set_hl(0, "PmenuSel", { bg = "NONE", fg = "#C5CDD9" })
vim.api.nvim_set_hl(0, "Pmenu", { fg = "#C5CDD9", bg = "NONE" })

vim.api.nvim_set_hl(0, "CmpItemAbbrDeprecated", { fg = "#7E8294", bg = "NONE", strikethrough = true })
vim.api.nvim_set_hl(0, "CmpItemAbbrMatch", { fg = "#82AAFF", bg = "NONE", bold = true })
vim.api.nvim_set_hl(0, "CmpItemAbbrMatchFuzzy", { fg = "#82AAFF", bg = "NONE", bold = true })
vim.api.nvim_set_hl(0, "CmpItemMenu", { fg = "#C792EA", bg = "NONE", italic = true })

vim.api.nvim_set_hl(0, "CmpItemKindField", { fg = "#EED8DA", bg = "#B5585F" })
vim.api.nvim_set_hl(0, "CmpItemKindProperty", { fg = "#EED8DA", bg = "#B5585F" })
vim.api.nvim_set_hl(0, "CmpItemKindEvent", { fg = "#EED8DA", bg = "#B5585F" })

vim.api.nvim_set_hl(0, "CmpItemKindText", { fg = "#C3E88D", bg = "#9FBD73" })
vim.api.nvim_set_hl(0, "CmpItemKindEnum", { fg = "#C3E88D", bg = "#9FBD73" })
vim.api.nvim_set_hl(0, "CmpItemKindKeyword", { fg = "#C3E88D", bg = "#9FBD73" })

vim.api.nvim_set_hl(0, "CmpItemKindConstant", { fg = "#FFE082", bg = "#D4BB6C" })
vim.api.nvim_set_hl(0, "CmpItemKindConstructor", { fg = "#FFE082", bg = "#D4BB6C" })
vim.api.nvim_set_hl(0, "CmpItemKindReference", { fg = "#FFE082", bg = "#D4BB6C" })

vim.api.nvim_set_hl(0, "CmpItemKindFunction", { fg = "#EADFF0", bg = "#A377BF" })
vim.api.nvim_set_hl(0, "CmpItemKindStruct", { fg = "#EADFF0", bg = "#A377BF" })
vim.api.nvim_set_hl(0, "CmpItemKindClass", { fg = "#EADFF0", bg = "#A377BF" })
vim.api.nvim_set_hl(0, "CmpItemKindModule", { fg = "#EADFF0", bg = "#A377BF" })
vim.api.nvim_set_hl(0, "CmpItemKindOperator", { fg = "#EADFF0", bg = "#A377BF" })

vim.api.nvim_set_hl(0, "CmpItemKindVariable", { fg = "#C5CDD9", bg = "#7E8294" })
vim.api.nvim_set_hl(0, "CmpItemKindFile", { fg = "#C5CDD9", bg = "#7E8294" })

vim.api.nvim_set_hl(0, "CmpItemKindUnit", { fg = "#F5EBD9", bg = "#D4A959" })
vim.api.nvim_set_hl(0, "CmpItemKindSnippet", { fg = "#F5EBD9", bg = "#D4A959" })
vim.api.nvim_set_hl(0, "CmpItemKindFolder", { fg = "#F5EBD9", bg = "#D4A959" })

vim.api.nvim_set_hl(0, "CmpItemKindMethod", { fg = "#DDE5F5", bg = "#6C8ED4" })
vim.api.nvim_set_hl(0, "CmpItemKindValue", { fg = "#DDE5F5", bg = "#6C8ED4" })
vim.api.nvim_set_hl(0, "CmpItemKindEnumMember", { fg = "#DDE5F5", bg = "#6C8ED4" })

vim.api.nvim_set_hl(0, "CmpItemKindInterface", { fg = "#D8EEEB", bg = "#58B5A8" })
vim.api.nvim_set_hl(0, "CmpItemKindColor", { fg = "#D8EEEB", bg = "#58B5A8" })
vim.api.nvim_set_hl(0, "CmpItemKindTypeParameter", { fg = "#D8EEEB", bg = "#58B5A8" })


local async_load_plugin

local set_hl = function(tbl)
  for group, conf in pairs(tbl) do
    vim.api.nvim_set_hl(0, group, conf)
  end
end

async_load_plugin = vim.loop.new_async(vim.schedule_wrap(function()
  colour.terminal_color()
  set_hl(plugin_syntax)
  async_load_plugin:close()
end))

function colour.colorscheme()
  vim.api.nvim_command("hi clear")

  vim.o.background = "dark"
  vim.o.termguicolors = true
  vim.g.colors_name = "my-base16"
  set_hl(syntax)
  async_load_plugin:send()
end

colour.base16 = b

return colour
