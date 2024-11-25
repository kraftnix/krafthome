-- local h = require 'utils.helper'
-- local make_telescope_command = h.make_telescope_command
-- local lt = require('legendary.toolbox')
return {
  -- easily create user commands
  {
    ':SayHello',
    function()
      print('hello world!')
    end,
    description = 'Say hello as a command',
  },
  { itemgroup = 'Nix',
    commands = {
      -- (make_telescope_command({'?', 'oldfiles', '[?] Find recently opened files'})),
      -- nix
      -- (make_telescope_command({ 'fnpg', function ()
      --   require('telescope.builtin').live_grep({ search_dirs = { "~/repos/NixOS/nixpkgs" } })
      -- end, 'Fuzzy search in Nix Packages' })),
    },
  },
  -- in-place filters, see :h legendary-tables or ./doc/table_structures/README.md
  -- { ':Glow', description = 'Preview markdown', filters = { ft = 'markdown' } },
}
