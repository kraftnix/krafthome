local h = require 'utils.helper'
local t = require 'utils.telescope.terminal'

local function tm(command, opts)
  return h.lazy_required_fn('terminal.mappings', command, opts)
end
local function tma(command, args1, args2)
  return h.lazy_required_fn('terminal.mappings', command, args1, args2)
end

local function mkTerminalMap(opts)
  return vim.tbl_extend('keep', opts, {
    modes = {"t"},
    opts = { noremap = true },
    is_nvim_command = false,
  })
end

return h.mapNixPlugin {
  { 'akinsho/toggleterm.nvim',
    enabled = false, -- replaced by `terminal.nvim`
    keys = {
      { "<C-Q>", ":ToggleTerm<cr>", noremap = true, mode = { "n", "x" } },
      { "<C-Q>", "<c-\\><c-n><cmd>ToggleTerm<cr>", noremap = true, mode = { "t" } },
      { '<C-\\><C-\\>', '<Esc>', noremap = true, mode = "t", desc = "Terminal: enable escape" },
      { '<Esc>', '<c-\\><c-n>', noremap = true, mode = "t", desc = "Terminal: allow escape passthrough" },
    },
    opts = {
      open_mapping = [[<C-Q>]],
      direction = "float",
      float_opts = {
        border = "double",
        winblend = 0,
      },
      persist_mode = true,
      persist_size = true,
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
    }
  },

  -- currently using a forked version
  { 'rebelot/terminal.nvim',
    dir = '~/repos/rebelot/terminal.nvim',
    nix_name = 'terminal-nvim',
    keycommands_meta = {
      group_name = 'Terminal',
      description = 'Terminal operations',
      icon = '',
      default_opts = { -- only applies to this lazy keygroup
        silent = true,
      }
    },
    keycommands = {
      { "<leader>ts",
        function()
          if require('legendary.toolbox').is_visual_mode() then
            local gvs = require("fzf-lua.utils").get_visual_selection
            require("terminal").send(1, gvs())
          else
            require("terminal").send(1, vim.api.nvim_get_current_line())
          end
        end,
        "[t]erm: [s]end current line/selection to term",
        'TerminalSendSelection',
        modes = { "v", "n" }
      },
      { '<C-Q>', tm('toggle'), 'Toggle terminal into a tab', 'TerminalToggle', modes = { "n", "v" } },
      { "<leader>tr", tm('run'), "[t]erminal, [r]un command (exits on completion)", 'TerminalRunTemp' },
      { "<leader>tk", tm('kill'), "[t]erminal, [k]ill current", 'TerminalKill' },
      { "]t", tm('cycle_next'), "[t]erminal, cycle next", 'TerminalNext' },
      { "[t", tm('cycle_prev'), "[t]erminal, cycle prev", 'TerminalPrev' },
      { "<leader>fT", t.telescope_terminals, 'Terminal Finder', 'Terminals' },
      -- { "<leader>tt", tm('move', { open_cmd = "tabe" }), 'TerminalMoveToTab' }, --notworking
      -- { 'TerminalMoveToggleTab', tm('toggle', { open_cmd = "tabe" }), "<leader>tO" }, --notworking
      -- { 'TerminalRun', "<leader>tR", tma('run', nil, { layout = { open_cmd = "enew" } }), }, --notworking
      -- { "<leader>tl", tm('move', { open_cmd = "belowright vnew" }), 'TerminalMoveBelowRight' }, --notworking
      -- { "<leader>tf", tm('move', { open_cmd = "float" }), 'TerminalMoveFloat' }, --notworking
    },
    keys = {
      { '<c-q>', function()
        tm'toggle'()
        vim.cmd 'tabp' --fix tab location
      end, noremap = true, mode = "t", desc = "Toggle terminal while in term mode" },
      { [[<c-\><c-\>]], '<Esc>', noremap = true, mode = "t", desc = "Terminal: enable escape" },
      { '<Esc>', [[<c-\><c-n>]], noremap = true, mode = "t", desc = "Terminal: allow escape passthrough" },
      { '<C-h>', [[<c-\><c-n><cmd>tabp<cr>]], noremap = true, mode = "t", desc = "Terminal: move tab left" },
      { '<C-l>', [[<c-\><c-n><cmd>tabn<cr>]], noremap = true, mode = "t", desc = "Terminal: move tab right" },
      { '<C-u>', [[<C-\><C-n><C-u>]], noremap = true, mode = "t", desc = "Terminal: Scroll up (and enter normal) in terminal." },
    },
    opts = {
      -- layout = { open_cmd = "tabe name=scratchpad" },
      layout = { open_cmd = "tabe" },
      cmd = { vim.o.shell },
      autoclose = false,
    },
    config = function (_, opts)
      local terminal = require "terminal"
      terminal.setup(opts)
      local htop = terminal.terminal:new({
          layout = { open_cmd = "float" },
          cmd = { "zenith" },
          autoclose = true,
      })

      vim.api.nvim_create_user_command("Zenith", function()
          htop:toggle(nil, true)
      end, { nargs = "?" })

      local nu = terminal.terminal:new({
        layout = { open_cmd = "float" },
        cmd = { "nu" },
        autoclose = true,
      })
      vim.api.nvim_create_user_command("Nushell", function()
          nu:toggle(nil, true)
      end, { nargs = "?" })


      -- automatically enter insert mode in terminal
      vim.api.nvim_create_autocmd({ "WinEnter", "BufWinEnter", "TermOpen" }, {
          callback = function(args)
              if vim.startswith(vim.api.nvim_buf_get_name(args.buf), "term://") then
                  vim.cmd("startinsert")
              end
          end,
      })
    end,
  }

}
