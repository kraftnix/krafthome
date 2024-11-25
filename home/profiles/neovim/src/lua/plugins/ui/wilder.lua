local h = require 'utils.helper'

return h.NixPlugin {
  'gelguy/wilder.nvim',
  -- current issues: https://github.com/gelguy/wilder.nvim/issues/187
  commit = "9929e1090dd84a60c1d1cc0220e0e35473c99b5e",
  enabled = false,
  -- nix_enable = false,
  dependencies = {
    'nixprime/cpsm'
  },
  -- build = ':UpdateRemotePlugins',
  config = function (_, opts)
    local wilder = require('wilder')
    opts = {
      modes = {':', '/', '?'},
      next_key = "<C-j>",
      previous_key = "<C-k>",
      accept_key = "<C-Space>",
      reject_key = "<C-e>",
    }
    wilder.setup(opts)

    -- this often breaks
    -- wilder.set_option('pipeline', {
    --   wilder.branch(
    --     wilder.python_file_finder_pipeline({
    --       file_command = function(ctx, arg)
    --         if string.find(arg, '.') ~= nil then
    --           return {'fd', '-tf', '-H'}
    --         else
    --           return {'fd', '-tf'}
    --         end
    --       end,
    --       dir_command = {'fd', '-td'},
    --       filters = {'cpsm_filter'},
    --     }),
    --     wilder.substitute_pipeline({
    --       pipeline = wilder.python_search_pipeline({
    --         skip_cmdtype_check = 1,
    --         pattern = wilder.python_fuzzy_pattern({
    --           start_at_boundary = 0,
    --         }),
    --       }),
    --     }),
    --     wilder.cmdline_pipeline({
    --       fuzzy = 2,
    --       -- fuzzy_filter = wilder.lua_fzy_filter(),
    --     }),
    --     {
    --       wilder.check(function(ctx, x) return x == "" end),
    --       wilder.history(),
    --     },
    --     wilder.python_search_pipeline({
    --       pattern = wilder.python_fuzzy_pattern({
    --         start_at_boundary = 0,
    --       }),
    --     })
    --   ),
    -- })

  --   local gradient = {
  --     '#f4468f', '#fd4a85', '#ff507a', '#ff566f', '#ff5e63',
  --     '#ff6658', '#ff704e', '#ff7a45', '#ff843d', '#ff9036',
  --     '#f89b31', '#efa72f', '#e6b32e', '#dcbe30', '#d2c934',
  --     '#c8d43a', '#bfde43', '#b6e84e', '#aff05b'
  --   }
  --   for i, fg in ipairs(gradient) do
  --     gradient[i] = wilder.make_hl('WilderGradient' .. i, 'Pmenu', {{a = 1}, {a = 1}, {foreground = fg}})
  --   end
  --
  --   local highlighters = {
  --     wilder.pcre2_highlighter(),
  --     wilder.basic_highlighter(),
  --   }
  --
  --   local make_renderer = function (prompt_position)
  --     prompt_position = prompt_position or 'bottom'
  --     local reverse = true
  --     if prompt_position == 'top' then
  --       reverse = false
  --     end
  --     return wilder.popupmenu_renderer(
  --       wilder.popupmenu_palette_theme({
  --         border = 'rounded',
  --         empty_message = wilder.popupmenu_empty_message_with_spinner(),
  --         -- highlighter = highlighters,
  --         highlights = {
  --          gradient = gradient,
  --         },
  --         prompt_position = prompt_position,
  --         reverse = reverse,
  --         highlighter = wilder.highlighter_with_gradient({
  --          wilder.pcre2_highlighter(),
  --          wilder.basic_highlighter(), -- or wilder.lua_fzy_highlighter(),
  --         }),
  --         left = {
  --           ' ',
  --           wilder.popupmenu_devicons(),
  --           wilder.popupmenu_buffer_flags({
  --             flags = ' a + ',
  --             icons = {['+'] = '󰏫', a = '󰈔', h = '󰈤'},
  --           }),
  --         },
  --         right = {
  --           ' ',
  --           wilder.popupmenu_scrollbar(),
  --         },
  --       })
  --     )
  --   end
  --
  --   -- simple renderer
  --   local wildmenu_renderer = wilder.wildmenu_renderer({
  --     mode = "float",
  --     highlighter = highlighters,
  --     separator = ' · ',
  --     left = {' ', wilder.wildmenu_spinner(), ' '},
  --     right = {' ', wilder.wildmenu_index()},
  --   })
  --
  --   wilder.set_option('renderer', wilder.renderer_mux({
  --     [':'] = make_renderer('top'),
  --     -- ['/'] = wildmenu_renderer,
  --     -- substitute = wildmenu_renderer,
  --     ['/'] = make_renderer('top'),
  --     substitute = make_renderer('top'),
  --   }))
  end
}
