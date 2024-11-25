local h = require 'utils.helper'
return h.mapNixPlugin {
  -- buffer manager
  { 'ThePrimeagen/harpoon',
    dependencies = {
      'nvim-telescope/telescope.nvim',
      'nvim-lua/plenary.nvim',
    },
    cmd = 'Harpoon',
    opts = {
      -- don't change tabline
      tabline = false,
      global_settings = {
        tabline = false,
      },
    },
    keycommands_meta = {
      group_name = 'Harpoon',
      description = 'Mark important buffers',
      icon = '🔱',
      default_opts = { -- only applies to this lazy keygroup
        silent = true,
      }
    },
    keycommands = {
      { '<leader>hf', 'Telescope harpoon marks', '[h]arpoon [f]ind marks', 'HarpoonTelescopeMarks' },
      { '<leader>hm', h.lr('harpoon.ui', 'toggle_quick_menu'), '[h]arpoon toggle quick [m]enu', 'HarpoonQuickMenu' },
      { '<leader>hh', h.lr('harpoon.mark', 'add_file'), '[hh]arpoon add mark', 'HarpoonAddMark' },
      { '<leader>hn', h.lr('harpoon.ui', 'nav_next'), '[h]arpoon go to [n]ext mark', 'HarpoonGoNext' },
      { '<leader>hp', h.lr('harpoon.ui', 'nav_prev'), '[h]arpoon go to [p]rev mark', 'HarpoonGoPrev' },
      { '<leader>ht', h.lr('harpoon.cmd-ui', 'toggle_quick_menu'), '[h]arpoon toggle [t]erminal quick menu', 'HarpoonTerminalToggle' },
    },
    keys = {
    },
    config = function (_, opts)
      require("harpoon").setup(opts)
      require("telescope").load_extension('harpoon')
    end
  },

  { "cbochs/portal.nvim",
    nix_name = 'portal-nvim',
    -- Optional dependencies
    dependencies = {
        'nvim-lua/plenary.nvim',
        {"cbochs/grapple.nvim", nix_disable = true, },
        "ThePrimeagen/harpoon"
    },
    keycommands_meta = {
      group_name = 'Portal',
      description = 'Jump around!',
      icon = '󰆡',
      default_opts = { -- only applies to this lazy keygroup
        silent = true,
      }
    },
    keycommands = {
      { '<leader>i', 'Portal jumplist forward', 'Portal jumplist forward', 'PortalJumplistForward' },
      { '<leader>o', 'Portal jumplist backward', 'Portal jumplist backward', 'PortalJumplistBackward' },
      { '<leader>]c', 'Portal changelist forward', 'Portal changelist forward', 'PortalChangelistForward' },
      { '<leader>[c', 'Portal changelist backward', 'Portal changelist backward', 'PortalChangelistBackward' },
      { '<leader>]h', 'Portal harpoon forward', 'Portal harpoon forward', 'PortalHarpoonForward' },
      { '<leader>[h', 'Portal harpoon backward', 'Portal harpoon backward', 'PortalHarpoonBackward' },
      { '<leader>]q', 'Portal quickfix forward', 'Portal quickfix forward', 'PortalQuickfixForward' },
      { '<leader>[q', 'Portal quickfix backward', 'Portal quickfix backward', 'PortalQuickfixBackward' },
      { '<leader>]g', 'Portal grapple forward', 'Portal grapple forward', 'PortalGrappleForward' },
      { '<leader>[g', 'Portal grapple backward', 'Portal grapple backward', 'PortalGrappleBackward' },
    },
  }
}
