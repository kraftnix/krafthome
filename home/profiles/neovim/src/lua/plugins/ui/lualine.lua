local h = require 'utils.helper'

-- prevents INSERT/VIRTUAL etc appearing in show messages
vim.opt.showmode = false

local function keymap()
  if vim.opt.iminsert:get() > 0 and vim.b.keymap_name then
    return '⌨ ' .. vim.b.keymap_name
  end
  return ''
end

return h.mapNixPlugin {

  -- status bar
  { 'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons', 'folke/noice.nvim', },
    opts = {
      options = {
        icons_enabled = true,
        section_separators = { left = '', right = '' },
        component_separators = { left = '', right = '' },
        always_divide_middle = true,
        globalstatus = false,
        lualine_bold = true,

        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
        },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {'filename'},
        lualine_x = {'location'},
        lualine_y = {},
        lualine_z = {}
      },
      winbar = { },
      inactive_winbar = {},
      extensions = {},
      tabline = {
        lualine_a = {
          { 'tabs',
            mode = 2,
            max_length = 3*vim.o.columns/4,
            use_mode_colors = true,
            draw_empty = true,
            fmt = function(name, context)
              -- Show + if buffer is modified in tab
              local buflist = vim.fn.tabpagebuflist(context.tabnr)
              local winnr = vim.fn.tabpagewinnr(context.tabnr)
              local bufnr = buflist[winnr]
              local mod = vim.fn.getbufvar(bufnr, '&mod')
              if name == 'default.nix' then
                local dirname = vim.fs.dirname(context.file)
                if dirname then
                  name = vim.fs.basename(dirname).." "
                end
              elseif context.buftype == "terminal" then
                name = name .. " "
              elseif context.filetype == "NeogitStatus" then
                name = name .. " 󰊢"
              elseif context.filetype == "DiffviewFiles" then
                name = name .. " "
              elseif name == "DiffviewFilePanel" then
                vim.print(context)
              end

              return name .. (mod == 1 and ' +' or '')
            end
          }
        },
        -- lualine_b = {'custom_fname'},
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {
          {
            'windows',
            use_mode_colors = true,
          },
        }
      },
    },

  -- -- tabline / topline
  -- { 'kdheepak/tabline.nvim',
  --   dependencies = { 'nvim-lualine/lualine.nvim', 'nvim-tree/nvim-web-devicons' },
  --   -- enabled = false,
  --   -- lazy = false,
  --   opts = {
  --     options = {
  --       max_bufferline_percent = 65, -- set to nil by default, and it uses vim.o.columns * 2/3
  --       show_tabs_always = true,
  --       show_devicons = true,
  --       show_filename_only = true,
  --       modified_icon = "~", -- change the default modified icon
  --       modified_italic = true, -- set to true by default; this determines whether the filename turns italic if modified
  --       show_tabs_only = true, -- this shows only tabs instead of tabs + buffers
  --     }
  --   },
  --   -- config = function()
  --   --   vim.cmd[[
  --   --     set guioptions-=e " Use showtabline in gui vim
  --   --     set sessionoptions+=tabpages,globals " store tabpages and globals in session
  --   --   ]]
  --   -- end,
  -- },


    keycommands_meta = {
      group_name = 'Tab Management',
      description = 'Lualine tab commands',
      icon = '󰓩',
      default_opts = { -- only applies to this lazy keygroup
        -- silent = true,
      }
    },
    keycommands = {
      { "<leader>rt", function ()
        local input = vim.fn.input('New Name: ')
        vim.cmd([[LualineRenameTab ]]..input)
      end, 'LualineRenameTab', cmd_gen_skip = true },
    },

    config = function (_, opts)
      local custom_fname = require('lualine.components.filename'):extend()
      local highlight = require'lualine.highlight'
      local colors = vim.g.all_colors
      local default_status_colors = { saved = colors.green, modified = colors.red }

      function custom_fname:init(options)
        custom_fname.super.init(self, options)
        self.status_colors = {
          saved = highlight.create_component_highlight_group(
            {bg = default_status_colors.saved}, 'filename_status_saved', self.options),
          modified = highlight.create_component_highlight_group(
            {bg = default_status_colors.modified}, 'filename_status_modified', self.options),
        }
        if self.options.color == nil then self.options.color = '' end
      end

      function custom_fname:update_status()
        local data = custom_fname.super.update_status(self)
        data = highlight.component_format_highlight(vim.bo.modified
          and self.status_colors.modified
          or self.status_colors.saved) .. data
        return data
      end

      opts = vim.tbl_deep_extend('force', opts, {
        sections = {
          lualine_a = {'mode'},
          lualine_b = {'branch', 'diff', 'diagnostics'},
          lualine_c = {
            { 'filename',
              newfile_status = true,
              path = 1,
            },
            'lsp_progress',
          },
          -- lualine_x = {'encoding', 'fileformat', 'filetype'},
          lualine_x = {

            -- -- show notify messages in lualine
            -- { require("noice").api.status.message.get_hl,
            --   cond = require("noice").api.status.message.has,
            -- },

            -- show command / keys
            { require("noice").api.status.command.get,
              cond = require("noice").api.status.command.has,
              color = { fg = colors.red },
            },

            -- show search in status line
            { require("noice").api.status.search.get,
              cond = require("noice").api.status.search.has,
              color = { fg = colors.red },
            },

            -- lazy show bool if there are updates
            -- { require("lazy.status").updates,
            --   clond = require("lazy.status").has_updates,
            --   color = { fg = "#ff9e64" },
            -- },

            -- show 'recording @q' macro in status line
            { require("noice").api.statusline.mode.get,
              cond = require("noice").api.statusline.mode.has,
              color = { fg = colors.red },
            },

            'encoding', 'fileformat', 'filetype'
          },
          lualine_y = {'progress'},
          lualine_z = {'location'}
        }
      })
      require('lualine').setup(opts)
      -- require('lualine').hide({
      --   place = {'tabline'}, -- The segment this change applies to.
      -- })
    end
  },
}
