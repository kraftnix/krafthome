local h = require 'utils.helper'
local mapDap = function (keycommand)
  -- keycommand[2] = h.lr('dap', keycommand[2])
  -- keycommand[2] = function ()
  --   require('dap').toggle_breakpoint()
  -- end
  keycommand[2] = ":lua require'dap'."..keycommand[2]..'<cr>'
  keycommand = h.mapSkipGen(keycommand)
  return keycommand
end
return h.mapNixPlugin {

  { "mfussenegger/nvim-dap",
    dependencies = {
      'nvim-telescope/telescope-dap.nvim',
      'theHamsta/nvim-dap-virtual-text',
    }
  },

  -- WARNING: nvim-nio not found
  --
  -- { 'rcarriga/nvim-dap-ui',
  --   requires = {
  --     "mfussenegger/nvim-dap",
  --     "nvim-neotest/nvim-nio",
  --   },
  --   opts = {},
  -- },

  { "jbyuki/one-small-step-for-vimkind",
    nix_name = 'one-small-step-for-vimkind-nvim',
    dependencies = {'mfussenegger/nvim-dap'},
    keycommands_meta = {
      group_name = 'DAP (Debugger)',
      description = 'Lua DAP Commands',
      icon = '🐛',
      default_opts = { -- only applies to this lazy keygroup
        silent = true,
      }
    },
    keycommands = {
      -- mapDap { '<leader>db', [[:lua require"dap".toggle_breakpoint()<CR>]], '[dap]: Toggle Breakpoint', 'DapToggleBreakpoint' },
      mapDap { '<leader>db', 'toggle_breakpoint()', '[dap]: Toggle [b]reakpoint', 'DapToggleBreakpoint' },
      mapDap { '<leader>dB', [[set_breakpoint(vim.fn.input('Breakpoint condition: '))]], '[dap]: [B]reakpoint with condition', 'DapBreakpointCondition' },--doesnt work
      mapDap { '<leader>dc', 'continue()', '[dap]: [c]ontinue', 'DapContinue' },
      mapDap { '<leader>di', [[step_into()]], '[dap]: step [i]nto','DapStepInto' },
      mapDap { '<leader>do', [[step_over()]], '[dap]: step [o]ver','DapStepOver' },
      mapDap { '<leader>dO', [[step_out()]], '[dap]: step [O]ut','DapStepOut' },
      { '<leader>dh', [[:lua require"dap.ui.widgets".hover()<CR>]], '[dap]: [h]over','DapHover' },
      { '<leader>ds', [[:lua require"osv".launch({port = 8086})<CR>]], '[dap]: [s]tart server','DapStart'},
      { '<leader>dl', [[:lua require"dap".set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>]], '[dap]: set [l]og breakpoint', 'DapBreakpointLog' },
      mapDap { '<leader>dr', [[repl_open()]], '[dap]: open [r]epl', 'DapReplOpen' },
    },
    config = function()
      local dap = require"dap"
      dap.configurations.lua = {
        {
          type = 'nlua',
          request = 'attach',
          name = "Attach to running Neovim instance",
        }
      }

      dap.adapters.nlua = function(callback, config)
        callback({ type = 'server', host = config.host or "127.0.0.1", port = config.port or 8086 })
      end
    end
  },

}
