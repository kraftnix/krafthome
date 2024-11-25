local h = require 'utils.helper'
return h.mapNixPlugin {

  { "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keycommands = {

      { "<leader>jj", h.lr('flash', 'jump'), desc = "Flash Jump", modes = { "n", "x", "o" } },
      { "<leader>js", h.lr('flash', 'treesitter'), desc = "Flash Treesitter", modes = { "n", "x", "o" } },
      { '<leader>jc', h.lr('flash', 'jump', {continue=true}), 'Flash: continue search' }, -- awesome

      -- awesome
      { '<leader>jw',
        function ()
          require('flash').jump({
            pattern = vim.fn.expand("<cword>"),
          })
        end,
        'Flash: search under word'
      },

      { '<leader>jl',
        h.lr('flash', 'jump', {
          search = { mode = "search", max_length = 0 },
          label = { after = { 0, 0 } },
          pattern = "^"
        }),
        'Flash: jump to a line'
      },

      { '<leader>ja',
        function()
          require("flash").jump({
            pattern = ".", -- initialize pattern with any char
            search = {
              mode = function(pattern)
                -- remove leading dot
                if pattern:sub(1, 1) == "." then
                  pattern = pattern:sub(2)
                end
                -- return word pattern and proper skip pattern
                return ([[\<%s\w*\>]]):format(pattern), ([[\<%s]]):format(pattern)
              end,
            },
            -- select the range
            jump = { pos = "range" },
          })
        end,
        desc = 'Flash: select any word'
      },

      { "<leader>jd",
        function()
          require("flash").jump({
            action = function(match, state)
              vim.api.nvim_win_call(match.win, function()
                vim.api.nvim_win_set_cursor(match.win, match.pos)
                vim.diagnostic.open_float()
              end)
              state:restore()
            end,
          })
        end,
        desc = 'Flash: search diagnostics'
      },

      -- More advanced example that also highlights diagnostics:
      { "<leader>jD",
        function()
          require("flash").jump({
            matcher = function(win)
              ---@param diag Diagnostic
              return vim.tbl_map(function(diag)
                return {
                  pos = { diag.lnum + 1, diag.col },
                  end_pos = { diag.end_lnum + 1, diag.end_col - 1 },
                }
              end, vim.diagnostic.get(vim.api.nvim_win_get_buf(win)))
            end,
            action = function(match, state)
              vim.api.nvim_win_call(match.win, function()
                vim.api.nvim_win_set_cursor(match.win, match.pos)
                vim.diagnostic.open_float()
              end)
              state:restore()
            end,
          })
        end,
        desc = 'Flash: search diagnostics'
      },

    },
    keys = {
      { "r", mode = "o", h.lr('flash', 'remote'), desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, h.lr('flash', 'treesitter_search'), desc = "Treesitter Search" },
      { '<c-s>', mode = { "c" }, h.lr('flash', 'toggle'), desc = "Toggle Flash Search" },
    },
  },

  { "nvim-telescope/telescope.nvim",
    optional = true,
    opts = function(_, opts)
      local function flash(prompt_bufnr)
        require("flash").jump({
          pattern = "^",
          label = { after = { 0, 0 } },
          search = {
            mode = "search",
            exclude = {
              function(win)
                return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "TelescopeResults"
              end,
            },
          },
          action = function(match)
            local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
            picker:set_selection(match.pos[1] - 1)
          end,
        })
      end
      opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
        mappings = {
          n = { s = flash },
          i = { ["<c-s>"] = flash },
        },
      })
    end,
  },

}
