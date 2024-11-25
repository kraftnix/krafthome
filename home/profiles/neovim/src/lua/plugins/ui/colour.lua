local h = require 'utils.helper'

---Extends a lazy plugin with a colourscheme
---@param opts table
---@param colourscheme string|nil
---@return NixLazyPluginSpec
local function mapColour(opts, colourscheme, enabled, default)
  local conf = {}
  enabled = enabled or true
  default = default or true
  if colourscheme and default and enabled then
    conf = {
      config = function ()
        vim.cmd.colorscheme(colourscheme)
      end
    }
  end
  return vim.tbl_extend('force', {
    enabled = enabled,
    lazy = false,
    priority = 2000,
  }, conf, opts)
end

local highFunction

return h.mapNixPlugin {

  -- highlight any #red or #aabbcc style colour
  { 'nvchad/nvim-colorizer.lua',
    opts = {}
  },

  mapColour ({
    "folke/tokyonight.nvim",
    priority = 9000,
    opts = {
      style = 'night',
      terminal_colors = true,
      lualine_bold = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
      },
      on_colors = function(colors)
        colors.hint = colors.orange
        colors.error = "#ff0000"
        colors.comment = colors.green2
        vim.g.all_colors = colors
      end,
      on_highlights = function(hl, c)
        local util = require("tokyonight.util")

        local fieldColour = c.red
        local keyword = c.green
        local stringColour = c.magenta

        -- local fieldColour = c.magenta
        -- local keyword = c.green
        -- local stringColour = c.orange

        -- local fieldColour = c.orange
        -- local keyword = c.magenta
        -- local stringColour = c.green

        local purple = "#f97cd8"
        local bold = function (opts) vim.tbl_extend('force', { style = { bold = true } }, opts) end
        local parameter = { fg = util.lighten (c.yellow, 0.5) }
        hl["@string"] = { fg = stringColour, }
        --- field/property
        hl["@field"] = { fg = fieldColour, }
        hl["@property"] = { fg = fieldColour, }
        --- parameter
        hl["@parameter"] = parameter
        hl["@variable"] = parameter
        --- keyword
        hl.Keyword = bold { fg = purple, bg = keyword }
        hl['@keyword'] = bold { fg = purple, bg = keyword }
        ---core
        hl['@keyword'] = bold { fg = purple, bg = keyword }
        hl["@boolean"] = { fg = c.cyan, }
        hl["@number"] = { fg = c.red, }
        --- Telescope
        hl.TelescopePromptBorder = { fg = c.orange, }
        hl.TelescopePromptTitle = { fg = c.orange, }
        hl.TelescopeResultsBorder = { fg = c.green, }
        hl.TelescopeResultsTitle = { fg = c.green, }
        hl.TelescopeResultsTitle = { fg = c.green, }
        --- LSP
        hl.DiagnosticUnnecessary = { fg = c.comment }
        -- Flash
        hl.FlashBackdrop = { fg = c.purple }
      end
    },
    config = function (_, opts)
      require('tokyonight').setup(opts)
      vim.cmd.colorscheme 'tokyonight-night'
      vim.g.tokyonight_colors = require 'tokyonight.colors'
    end
  }),

  { 'hiphish/rainbow-delimiters.nvim',
    dependencies = {
      -- 'nvim-treesitter/playground',
    },
    config = function()
      local rainbow_delimiters = require 'rainbow-delimiters'
      require'rainbow-delimiters.setup'.setup {
        strategy = {
          [''] = rainbow_delimiters.strategy['global'],
          vim = rainbow_delimiters.strategy['local'],
        },
        query = {
          [''] = 'rainbow-delimiters',
          lua = 'rainbow-blocks',
        },
        highlight = {
          'RainbowDelimiterRed',
          'RainbowDelimiterYellow',
          'RainbowDelimiterGreen',
          'RainbowDelimiterBlue',
          'RainbowDelimiterOrange',
          'RainbowDelimiterCyan',
          'RainbowDelimiterViolet',
        },
      }
    end
  },

  -- mapColour ({ "glepnir/zephyr-nvim"}, 'zephyr', false ),
  -- mapColour ({
  --   "tiagovla/tokyodark.nvim",
  --   nix_disable = true,
  --   opts = {
  --     -- transparent_background = true,
  --   },
  --   -- config = function(_, opts)
  --   --     require("tokyodark").setup(opts) -- calling setup is optional
  --   --     vim.cmd [[colorscheme tokyodark]]
  --   -- end,
  -- }),

  -- -- alright theme, v similar to folke/tokyonight
  -- mapColour ({
  --   "shaunsingh/moonlight.nvim",
  --   nix_disable = true,
  -- }, 'moonlight', true, false),

  -- -- base16 mapper
  -- mapColour ({ "RRethy/nvim-base16",
  --   nix_disable = true,
  --   opts = (require 'colour').base16,
  --   main = 'base16-colorscheme',
  -- }, nil, true, false),
  --
  -- -- pretty great multi theme with active toggle
  -- mapColour ({ "ray-x/starry.nvim",
  --   nix_disable = true,
  -- }, nil, true, false),

}
