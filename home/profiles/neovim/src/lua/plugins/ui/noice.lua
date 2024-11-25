local h = require 'utils.helper'
local popupmenu_backend = 'nui'
if vim.g.enable_cmp_cmdline then
  popupmenu_backend = 'cmp'
end
return h.mapNixPlugin {

  { "rcarriga/nvim-notify",
    keys = {
      { "<leader>nu",
        function()
          require("notify").dismiss({ silent = true, pending = true })
        end,
        desc = "Delete all Notifications",
      },
    },
    opts = {
      timeout = 5000,
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.75)
      end,
    },
  },

  { "folke/noice.nvim",
    dependencies = {
      "muniftanjim/nui.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    keycommands_meta = {
      --source_plugin = legendary (from lazy.main)
      group_name = 'Noice',
      description = 'Noice UI options',
      icon = '󰐯',
      default_opts = { -- only applies to this lazy keygroup
        silent = true,
      }
    },
    keycommands = {
      -- { '<leader>nn', 'Noice', 'ope[n] [n]oice', cmd_gen_skip = true },
      { '<leader>nh', 'Noice history', '[n]oice [h]istory', 'NoiceHistory' },
      { '<leader>ns', 'Noice stats', '[n]oice view [s]tats', 'NoiceStats' },
      { '<leader>nR', 'Noice routes', '[n]oice [r]outes', 'NoiceRoutes' },
      { '<leader>na', 'Noice all', '[n]oice [a]ll', 'NoiceAll' },
      { '<leader>nf', 'Noice telescope', '[n]oice find all [t]elescope', 'NoiceTelescope' },
      { '<leader>nll', 'Noice last', '[n]oice get [l]ast [l]og', 'NoiceLast' },
      { '<leader>nlL', 'Noice log', '[n]oice open [lL]og file', 'NoiceLog' },
      { '<leader>nlc', 'Noice config', '[n]oice [l]ist [c]onfig', 'NoiceConfig' },
    },
    event = "VeryLazy",
    opts = {
      -- debug = true,
      cmdline = {
        enabled = true,
        view = "cmdline_popup",
        -- view = "cmdline",
        opts = {},
      },
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          -- ["cmp.entry.get_documentation"] = false,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      presets = {
        -- bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = true,
        lsp_doc_border = true,
      },

      routes = {
        -- { -- reroute long notifications to splits
        --   filter = {
        --     event = "notify",
        --     min_height = 15
        --   },
        --   view = 'split'
        -- },
        { -- filter out treesitter errors
          view = 'split',
          filter = {
            event = { "msg_show", "msg_showmode" },
            find = "treesitter/highlighter",
          },
        },
        { -- route shortmess messages to mini view
          view = "mini",
          filter = {
            event = { "msg_show", "msg_showmode" },
            ["not"] = {
              kind = { "confirm", "confirm_sub" },
            },
          },
        },
        --- ??
        -- {
        --   filter = {
        --     event = "cmdline",
        --     find = "^%s*[/?]",
        --   },
        --   view = "cmdline",
        -- },
      },

      -- show together
      views = {
        cmdline_popup = {
          -- position = {
          --   row = 5,
          --   col = "50%",
          -- },
          -- size = {
          --   width = 60,
          --   height = "auto",
          -- },
          border = {
            style = "none",
            padding = { 2, 3 },
          },
          filter_options = {},
          win_options = {
            winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder",
          },
        },
        popupmenu = {
          backend = popupmenu_backend,
          relative = "editor",
          position = {
            row = 8,
            col = "50%",
          },
          size = {
            width = 80,
            height = 10,
          },
          border = {
            style = "rounded",
            padding = { 0, 1 },
          },
          win_options = {
            winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
          },
        },
      },
    },
  },

  { "folke/noice.nvim",
    opts = function(_, opts)
      -- ?
      opts.routes = opts.routes or {}
      -- table.insert(opts.routes, {
      --   filter = {
      --     event = "notify",
      --     find = "No information available",
      --   },
      --   opts = { skip = true },
      -- })

      -- require("noice").redirect(function()
      --   print("test")
      -- end, {{
      --   view = "split",
      --   -- filter = { event = "msg_show" },
      -- }})

      -- Adding the following keymap, will redirect the active cmdline when pressing
      -- `<Alt-Enter>`. The cmdline stays open, so you can change the command and execute
      -- it again. When exiting the cmdline, the popup window will be focused.
      local redirect = function()
        require('noice').redirect(vim.fn.getcmdline())
      end
      vim.keymap.set('c', '<m-cr>', redirect, { desc = 'Redirect Cmdline' })

      -- LSP HOVER DOC SCROLLING
      vim.keymap.set({ "n", "i", "s" }, "<c-f>", function()
        if not require("noice.lsp").scroll(4) then
          return "<c-f>"
        end
      end, { silent = true, expr = true })

      vim.keymap.set({ "n", "i", "s" }, "<c-b>", function()
        if not require("noice.lsp").scroll(-4) then
          return "<c-b>"
        end
      end, { silent = true, expr = true })

      local focused = true
      vim.api.nvim_create_autocmd("FocusGained", {
        callback = function()
          focused = true
        end,
      })
      vim.api.nvim_create_autocmd("FocusLost", {
        callback = function()
          focused = false
        end,
      })

      -- ?
      -- table.insert(opts.routes, 1, {
      --   filter = {
      --     ["not"] = {
      --       event = "lsp",
      --       kind = "progress",
      --     },
      --     cond = function()
      --       return not focused
      --     end,
      --   },
      --   view = "notify_send",
      --   opts = { stop = false },
      -- })

      -- show in lualine instead
      -- -- show @recording in notification
      -- opts.routes = opts.routes or {}
      -- table.insert(opts.routes, {
      --   view = "notify",
      --   filter = { event = "msg_showmode" },
      -- })

      opts.commands = {
        all = {
          -- options for the message history that you get with `:Noice`
          view = "split",
          opts = { enter = true, format = "details" },
          filter = {},
        },
      }
      opts.status = { lsp_progress = { event = "lsp", kind = "progress" } }

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function(event)
          vim.schedule(function()
            require("noice.text.markdown").keys(event.buf)
          end)
        end,
      })
    end,
  },
}
