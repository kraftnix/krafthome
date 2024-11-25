local h = require 'utils.helper'
return h.NixPlugin {
  'axkirillov/easypick.nvim',
  nix_name = "easypick-nvim",
  cmd = 'Easypick',
  dependencies = { 'nvim-telescope/telescope.nvim' },
  keys = {
    { '<leader>lae', ':Easypick<cr>', desc = "list [a]ll [e]asypickers", mode = { 'n' }, noremap = false, silent = false }
  },
  config = function ()
    local easypick = require("easypick")

    -- only required for the example to work
    local base_branch = "develop"

    -- a list of commands that you want to pick from
    local list = [[
    << EOF
    :Telescope live_grep
    :Telescope find_files
    :Git blame
    EOF
    ]]

    easypick.setup({
      pickers = {
        {
          name = "secrets",
          command = "ls secrets",
          previewer = easypick.previewers.default(),
          action = easypick.actions.nvim_commandf("tabe secrets/%s"),
        },

        {
          name = "hosts",
          command = "ls hosts",
          previewer = easypick.previewers.default(),
          action = easypick.actions.nvim_commandf("tabe hosts/%s"),
        },

        {
          name = "command_palette",
          command = "cat " .. list,
                            -- pass a pre-configured action that runs the command
          action = easypick.actions.nvim_commandf("%s"),
                            -- you can specify any theme you want, but the dropdown looks good for this example =)
          opts = require('telescope.themes').get_dropdown({})
        },

        -- diff current branch with base_branch and show files that changed with respective diffs in preview
        {
          name = "changed_files",
          command = "git diff --name-only $(git merge-base HEAD " .. base_branch .. " )",
          previewer = easypick.previewers.branch_diff({base_branch = base_branch})
        },

        -- list files that have conflicts with diffs in preview
        {
          name = "conflicts",
          command = "git diff --name-only --diff-filter=U --relative",
          previewer = easypick.previewers.file_diff()
        },
      }
    })
  end
}
