local h = require 'utils.helper'
return h.mapNixPlugin {

  -- search/replace in multiple files
  -- need to set up
  -- https://github.com/nvim-pack/nvim-spectre
  { "nvim-pack/nvim-spectre",
    cmd = "Spectre",
    -- stylua: ignore
    keycommands_meta = {
      group_name = 'Spectre Search',
      description = 'Smarter search/repalce',
      icon = '󰊠',
      default_opts = { silent = true, }
    },
    keycommands = {
      { "<leader>rss", 'Spectre', "Toggle Spectre (search)" },
      { "<leader>rss", h.lr('spectre', 'toggle'), "Toggle Spectre (search)" },
      { "<leader>rsw", h.lr('spectre', 'open_visual', {select_work=true}), "Search current word" },
      { "<leader>rsw", '<esc><cmd>lua require("spectre").open_visual()<cr>', "Search current word (visual)", mode = 'v', is_nvim_command = true },
      { "<leader>rsf", h.lr('spectre', 'open_file_search', {select_work=true}), "Search on current file", },
    },
    opts = {
      open_cmd = "noswapfile vnew",
      mapping = { }
    },
  },

  -- markdown previewer
  { 'ellisonleao/glow.nvim',
    config = true,
    cmd = "Glow"
  },

  -- documentation lookup
  { "danymat/neogen",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = true,
    keycommands_meta = {
      group_name = 'Documentation',
      description = 'Documentation search + generation',
      icon = '📰',
      default_opts = { -- only applies to this lazy keygroup
        silent = true,
      }
    },
    keycommands = {
      { '<leader>dgd', h.lr('neogen', 'generate'), '[d]ocumentation [g]eneration ([d]efault)', 'GenerateDocsDefault' }
    }
  },

  -- documentation lookup
  { 'luckasRanarison/nvim-devdocs',
    cmd = 'DevdocsOpen',
    opts = {
      mappings = { -- keymaps for the doc buffer
        open_in_browser = "<C-F><C-F>"
      },
      ensure_installed = {
        'lua',
        'nix',
        'nushell',
        'rust',
        'css',
        'html',
        'http',
        'javascript',
        'git',
        'i3',
        'jq',
        'postgresql',
        'python'
      }, -- get automatically installed
    },
    keycommands = {
      { '<leader>lfd', 'DevdocsOpenCurrentFloat', 'lookup devdocs for current filetype', group = 'Documentation' },
      { '<leader>fdd', 'DevdocsOpen', '[d]evdocs documentation lookup', group = 'Documentation' },
      { '<leader>fdi', 'DevdocsInstall', '[d]evdocs [i]nstall', group = 'Documentation' },
      { '<leader>fdu', 'DevdocsUpdate', '[d]evdocs [u]pdate', group = 'Documentation' },
    }
  },

}
