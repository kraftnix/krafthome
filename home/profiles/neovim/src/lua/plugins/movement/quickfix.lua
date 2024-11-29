local h = require 'utils.helper'
local fzfVim = {
  'junegunn/fzf.vim',
  nix_name = "fzf-vim";
  nix_disable = true,
  dependencies = { 'junegunn/fzf' },
  keycommands_meta = {
    group_name = 'FzfVim',
    description = 'FzfVim (fzf function like telescope)',
    icon = '🔍',
  },
  keycommands = {
    { '<leader>lfff', ':Files<CR>', 'Open fzf files list', is_nvim_command = true },
    { '<leader>lff_', ':GFiles<CR>', 'Open fzf git files', is_nvim_command = true },
    { '<leader>lffb', ':Buffers<CR>', 'Open fzf buffers finder', is_nvim_command = true },
    { '<leader>lffc', ':Colors<CR>', 'Open fzf colourschmes', is_nvim_command = true },
    { '<leader>lffC', ':Changes<CR>', 'Open fzf changes', is_nvim_command = true },
    { '<leader>lffg', ':Lines<CR>', 'Open fzf fuzzy search in current buffer', is_nvim_command = true },
    { '<leader>lffG', ':BLines<CR>', 'Open fzf fuzzy search in open buffers', is_nvim_command = true },
    { '<leader>lffw', ':Windows<CR>', 'Open fzf windows', is_nvim_command = true },
    { '<leader>lffh', ':History<CR>', 'Open fzf file history (previously opened)', is_nvim_command = true },
    { '<leader>lff:', ':History:<CR>', 'Open fzf command history', is_nvim_command = true },
    { '<leader>lff/', ':History/<CR>', 'Open fzf search history', is_nvim_command = true },
    { '<leader>lffs', ':Snippets<CR>', 'Open fzf snippets', is_nvim_command = true },
    { '<leader>lffm', ':Commands<CR>', 'Open fzf commands', is_nvim_command = true },
  },
}
return h.mapNixPlugin {

  fzfVim,

  -- quickfix list with a preview + ability to open in splits/tabs
  { 'kevinhwang91/nvim-bqf',
    ft = 'qf',
    dependencies = { fzfVim },
    keycommands_meta = {
      group_name = 'Quickfix',
      description = 'Quickfix (and location list)',
      icon = '🩹',
      default_opts = { -- only applies to this lazy keygroup
        silent = true,
      }
    },
    keycommands = {
      { '<leader>lt', 'BqfAutoToggle', 'Enable/Disable auto quickfix toggle', cmd_gen_skip = true },
      -- Diagnostic keymaps
      -- { 'n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' } },
      -- { 'n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' } },
    },
    opts = {
      filter = {
        fzf = {
          action_for = { ['ctrl-s'] = 'split', ['ctrl-t'] = 'tab drop' },
          extra_opts = { '--bind', 'ctrl-o:toggle-all', '--prompt', '> ' }
        }
      }
    },
  },

  -- TODO(remove): can be replaced by keymaps/legendary/many things
  -- extremely simple plugin that adds a toggle for quickfix list
  { 'milkypostman/vim-togglelist',
    keycommands = {
      { '<leader>lq', ':call ToggleQuickfixList()<cr>', 'Open quickfix list', is_nvim_command = true, group = 'Quickfix' },
      { '<leader>lQ', ':call ToggleLocationList()<cr>', 'Open location list', is_nvim_command = true, group = 'Quickfix' },
    },
    init = function()
      vim.g.toggle_list_no_mappings = true
    end
  }
}
