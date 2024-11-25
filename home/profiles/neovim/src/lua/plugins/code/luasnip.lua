local h = require('utils.helper')
return h.NixPlugin {
  'l3mon4d3/luasnip',
  dependencies = {
    'benfowler/telescope-luasnip.nvim',
    'rafamadriz/friendly-snippets'
  },
  keycommands_meta = {
    group_name = 'Luasnip',
    description = 'Snippets generation + editing',
    icon = '🖇️',
    default_opts = { -- only applies to this lazy keygroup
      silent = true,
    }
  },
  keycommands = {
    { '<leader>sf', 'Telescope luasnip', "Luasnip [S]nippets." },
    { '<leader>se', h.lr("luasnip.loaders", 'edit_snippet_files'), "Edit LuaSnip Snippets." },
    { '<leader>ss', h.lr("luasnip", 'log.open'), "Open LuaSnip log" },
    { '<leader>sp', h.lr("luasnip", 'log.ping'), "Ping LuaSnip log to check it is working." },
    { '<leader>sr', h.lr("luasnip.loaders.from_lua", 'load', {paths = "./lua/snippets"}), "Reload local lua snippets" },
  },
  opts = {},
  config = function (_, opts)
    require('luasnip').setup(opts)
    require('luasnip.loaders.from_vscode').lazy_load()
    require('luasnip.loaders.from_lua').lazy_load({ paths = "./lua/snippets" })
    -- allow loading from current dir
    -- require("luasnip.loaders.from_lua").load({paths = {vim.fn.getcwd() .. "/.luasnippets/"}})

    require('telescope').load_extension "luasnip"
  end
}
