local h = require 'utils.helper'
return h.mapNixPlugin {

  -- fancy split/join of arrays/sets etc. using treesitter
  { "Wansmer/treesj",
    keycommands = {
      { "<leader>J", "TSJToggle", "Join Toggle", cmd_gen_skip = true, group = 'TreeSitter' },
    },
    opts = {
      use_default_keymaps = false,
      max_join_length = 250,
    },
  },

  -- -- replace/add/remove brackets/quotes using treesitter objects
  -- { 'kylechui/nvim-surround',
  --   -- enabled = false,
  --   version = "*", -- Use for stability; omit to use `main` branch for the latest features
  --   event = "VeryLazy",
  --   opts = {}
  -- },

  { 'NMAC427/guess-indent.nvim',
    -- enabled = false,
    nix_disable = true,
    opts = {
      auto_cmd = true,
    }
  },
}
