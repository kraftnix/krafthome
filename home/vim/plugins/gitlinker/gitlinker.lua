local gitlinker = require('gitlinker')
gitlinker.setup({
  callbacks = {
    ["gitea.home.lan"] = require "gitlinker.hosts".get_gitea_type_url,
  },
  opts = {
    action_callback = function(url)
      -- yank to unnamed register
      vim.api.nvim_command('let @" = \'' .. url .. '\'')
      -- copy to the system clipboard using OSC52
      vim.fn.OSCYank(url)
    end,
  },
})
