local h = require 'utils.helper'

--[[

vim.ui.select({ 'tabs', 'spaces' }, {
	prompt = 'Select tabs or spaces:',
	format_item = function(item)
		return "I'd like to choose " .. item
	end,
}, function(choice)
		if choice == 'spaces' then
			vim.print('spaces')
		else
			vim.print('tabs')
		end
	end)

--]]

return h.mapNixPlugin {

  -- scrolling changes, may feel a little lagy, not sure
  -- too laggy
  { "karb94/neoscroll.nvim",
    enabled = false,
    config = function ()
      require('neoscroll').setup({
        easing_function = "quadratic"
      })
      local t = {}
      local scrollspeed = 100
      -- local easingfunction = [['sine']]
      local easingfunction = [['circular']]
      -- Syntax: t[keys] = {function, {function arguments}}
      t['<C-u>'] = {'scroll', {'-vim.wo.scroll', 'true', tostring(scrollspeed), easingfunction}}
      t['<C-d>'] = {'scroll', { 'vim.wo.scroll', 'true', tostring(scrollspeed), easingfunction}}
      t['<C-b>'] = {'scroll', {'-vim.api.nvim_win_get_height(0)', 'true', '450'}}
      t['<C-f>'] = {'scroll', { 'vim.api.nvim_win_get_height(0)', 'true', '450'}}
      t['<C-y>'] = {'scroll', {'-0.10', 'false', '100'}}
      t['<C-e>'] = {'scroll', { '0.10', 'false', '100'}}
      t['zt']    = {'zt', {'250'}}
      t['zz']    = {'zz', {'250'}}
      t['zb']    = {'zb', {'250'}}

      require('neoscroll.config').set_mappings(t)
    end
  },

  -- noice is better
  -- { "arkav/lualine-lsp-progress", nix_disable = true },

  -- fancy windows for vim.ui.select
  { 'stevearc/dressing.nvim',
    event = "VeryLazy",
    -- enabled = false, -- replaced by noice
    dependecies = { 'nvim-telescope/telescope.nvim' },
    main = 'dressing',
    opts = {
      default_prompt = "Input: ",
      insert_only = false,
      start_in_insert = true,
      -- backend = { "telescope" },
      backend = { "nui" },
      select = {
        telescope = require("telescope.themes").get_ivy()
        -- telescope = {
        --   layout_config = {
        --     prompt_position = "bottom",
        --     vertical = {
        --       width = 0.97,
        --       height = 0.99,
        --       preview_cutoff = 10,
        --     },
        --     horizontal = {
        --       preview_cutoff = 10,
        --     },
        --   },
        -- }
      },
    }
  },

  -- auto-resize windows
  { "anuvyklack/windows.nvim",
    enabled = false, -- weird behaviour in Diffview with no easy way to disable in certain buffers
    event = "WinNew",
    dependencies = {
      -- { "anuvyklack/middleclass", nix_name = 'middleclass-nvim' },
      { "anuvyklack/middleclass", nix_disable = true, },
      { "anuvyklack/animation.nvim", enabled = false },
    },
    keycommands = {
      h.mapSkipGen { "<leader>z", "WindowsMaximize", "[z]oom current buffer in/out", group = 'buffer management', cmd_gen_skip = true },
    },
    config = function()
      vim.o.winwidth = 5
      vim.o.equalalways = false
      require("windows").setup({
        animation = { enable = false, duration = 150 },
      })
    end,
  },

  --[[Debug Info

  -- toggle trouble with optional mode
  require("trouble").toggle(mode?)

  -- open trouble with optional mode
  require("trouble").open(mode?)

  -- close trouble
  require("trouble").close()

  -- jump to the next item, skipping the groups
  require("trouble").next({skip_groups = true, jump = true});

  -- jump to the previous item, skipping the groups
  require("trouble").previous({skip_groups = true, jump = true});

  -- jump to the first item, skipping the groups
  require("trouble").first({skip_groups = true, jump = true});

  -- jump to the last item, skipping the groups
  require("trouble").last({skip_groups = true, jump = true});

  --]]

  { "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keycommands = {
      { "<leader>tt", h.lr('trouble','toggle'), "[t]oggle [t]rouble", },
    },
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
  },

  -- -- simple tabline
  -- { 'echasnovski/mini.nvim',
  --   name = "mini.tabline",
  --   enabled = false,
  --   opts = {}
  -- },

  { "axieax/urlview.nvim",
    keycommands = {
      { '<leader>lfub', 'UrlView', '[l]: [f]ind [u]rls in the current [b]uffer' },
      { '<leader>lful', 'UrlView lazy', '[l]: [f]ind [u]rls of your [l]azy plugins' },
    },
    config = function()
      require("urlview").setup({
        -- custom configuration options --
      })
    end,
  },

  -- custom highlights for comments
  { "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keycommands = {
      { '<leader>lfc', 'TodoTrouble', 'Add all todo items to quickfix list' },
      { ']T', h.lr('todo-comments', 'jump_next'), 'TODO Comment next' },
      { '[T', h.lr('todo-comments', 'jump_prev'), 'TODO Comment prev' },
    },
    opts = {
      keywords = {
        WORKAROUND = { icon = "🛠️", color = "error" }
      },
      -- pattern = [[\b(KEYWORDS)\(\):]],
      highlight = {
        -- vimgrep regex, supporting the pattern TODO(name):
        pattern = [[.*<((KEYWORDS)%(\(.{-1,}\))?):]],
      },
      search = {
        -- ripgrep regex, supporting the pattern TODO(name):
        pattern = [[\b(KEYWORDS)(\(\w*\))*:]],
      },
    }
  },

  -- Add indentation guides lines
  { 'lukas-reineke/indent-blankline.nvim',
    enabled = false, -- replaced by mini.indentscope
    main = "ibl",
    opts = { },
  },

  -- tabline -- wip attempt
  { 'nanozuki/tabby.nvim',
    lazy = false,
    enabled = false,
    dependecies = { 'nvim-tree/nvim-web-devicons' },
    keys = {
      { '<leader>tmp', ':-tabmove<cr>', noremap = true, desc = '[t]ab [m]ove to [p]revious position' },
      { '<leader>tmn', ':-tabmove<cr>', noremap = true, desc = '[t]ab [m]ove to [n]ext position' },
    },
    config = function (_, opts)

      local theme = {
        fill = 'TabLineFill',
        -- Also you can do this: fill = { fg='#f2e9de', bg='#907aa9', style='italic' }
        head = 'TabLine',
        current_tab = 'TabLineSel',
        tab = 'TabLine',
        win = 'TabLine',
        tail = 'TabLine',
      }
      require('tabby.tabline').set(function(line)
        return {
          {
            { '  ', hl = theme.head },
            line.sep('', theme.head, theme.fill),
          },
          line.tabs().foreach(function(tab)
            local hl = tab.is_current() and theme.current_tab or theme.tab
            local tabname = tab.name()
            if tabname == "default.nix" then
              tabname = vim.fs.dirname(vim.fn.getcwd()) .. '❄️'
            end
            return {
              line.sep('', hl, theme.fill),
              tab.is_current() and '' or '󰆣',
              tab.number(),
              tabname,
              tab.close_btn(''),
              line.sep('', hl, theme.fill),
              hl = hl,
              margin = ' ',
            }
          end),
          line.spacer(),
          line.wins_in_tab(line.api.get_current_tab()).foreach(function(win)
            return {
              line.sep('', theme.win, theme.fill),
              win.is_current() and '' or '',
              win.buf_name(),
              line.sep('', theme.win, theme.fill),
              hl = theme.win,
              margin = ' ',
            }
          end),
          {
            line.sep('', theme.tail, theme.fill),
            { '  ', hl = theme.tail },
          },
          hl = theme.fill,
        }
      end)
    end
  },
}
