local h = require 'utils.helper'
return h.mapNixPlugin {

  -- use external file managers in floating windows
  { 'is0n/fm-nvim',
      -- { '<leader>-', ':lua FmDir("Ranger")<cr>', desc = "Ranger open in current dir", mode = {'n'} },
      -- { '<leader>_', ':Ranger ~', desc = "Ranger open in home dir", mode = {'n'} },
      -- { '<leader>ab', ':lua FmDir("Broot")<cr>', desc = "[b]root open in curr dir", mode = {'n'} },
      -- { '<leader>aD', ':Xplr ~<cr>', desc = "Xplr open in home [D]ir", mode = {'n'} },
      -- { '<leader>aB', ':lua FmDir("Broot")<cr>', desc = "[B]root open in curr dir", mode = {'n'} },
      -- { '<leader>ad', ':lua FmDir("Xplr")<cr>', desc = "Xplr open in curr [d]ir", mode = {'n'} },
    keycommands_meta = {
      --source_plugin = legendary (from lazy.main)
      group_name = 'File Manager',
      description = 'File Manager related commands',
      icon = '',
      default_opts = { -- only applies to this lazy keygroup
        silent = true,
      }
    },
    keycommands = {
      { '<leader>lar', h.FmDirWrap('Ranger'), "Ranger open in current dir" },
      { '<leader>laR', 'Ranger ~', "Ranger open in home dir", 'RangerHome' },
      { '<leader>lab', 'Broot', "[b]root open in curr dir" },
      { '<leader>laD', 'Xplr ~', "Xplr open in home [D]ir", 'XplrHome' },
      { '<leader>laB', 'Broot ~', "[B]root open in [~]home dir", 'Broot ~'},
      { '<leader>lad', 'Xplr', "Xplr open in curr [d]ir" },
    },
    opts = {
      broot_conf = "~/.config/broot/conf.hjson",
      cmds = {
        broot = "broot --out /tmp/fm-nvim",
        ranger = "ranger",
        xplr = "xplr",
      },
      edit_cmd = "edit",
      mappings = {
        ESC = ":q<CR>",
        edit = "<C-e>",
        horz_split = "<C-h>",
        tabedit = "<C-t>",
        vert_split = "<C-v>",
      },
      ui = {
        default = "float",
        float = {
          blend = 0,
          border = "rounded",
          border_hl = "FloatBorder",
          float_hl = "Normal",
          height = 0.9,
          width = 0.9,
          x = 0.5,
          y = 0.5,
        }
      }
    },
  },

  -- native file-manager with support for remotes
  { 'stevearc/oil.nvim',
    opts = {
      default_file_explorer = true,
      columns = {
        "icon",
        -- "permissions",
        -- "size",
        -- "mtime"
      },
      buf_options = {
        buflisted = true
      },
      skip_confirm_for_simple_edits = true,
      view_options = {
      },
      -- keymaps = {
      --   ["C-j"] = "actions.select",
      --   ["C-k"] = "actions.parent",
      -- },
    },
    lazy = false,
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    keycommands_meta = { default_group = 'File Manager' },
    keycommands = {
      { "<leader>-", "Oil", "Open (Oil) parent directory.", },
      { "<leader>_", "Oil ~", "Open (Oil) parent directory.", 'OilHome', },
    },
  },

  { "nvim-neo-tree/neo-tree.nvim",
    keycommands_meta = { default_group = 'File Manager' },
    keycommands = {
      { "<leader>lat", "Neotree toggle", "NeoTree toggle", },
    },
    opts = {}
  },

  { "mikavilpas/yazi.nvim",
    nix_name = "yazi-nvim",
    event = "VeryLazy",
    keycommands_meta = { default_group = 'File Manager' },
    keycommands = {
      { '<leader>lay', function()
        require'yazi'.yazi(nil, vim.fn.getcwd())
      end, 'Yazi open in current dir', 'Yazi' },
      { '<leader>laY', function()
        require'yazi'.yazi(nil, '~')
      end, 'Yazi open in home dir', 'YaziHome' },
    },
    opts = {
      open_for_directories = true,
    },
  },
}
