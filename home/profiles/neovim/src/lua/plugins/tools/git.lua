local h = require 'utils.helper'

function GitCurrentBranchName()
  local branch = vim.fn.system("git branch --show-current 2> /dev/null | tr -d 'n'")
  if branch ~= "" then
    return branch
  else
    return ""
  end
end

return h.mapNixPlugin {

  --- not as nice as the in built quickfix list + next hunk jumping
  { "radyz/telescope-gitsigns",
    nix_disable = true,
    dependencies = {
      "lewis6991/gitsigns.nvim",
      "nvim-telescope/telescope.nvim",
    },
    keycommands_meta = { default_group = 'Telescope' },
    keycommands = {
      { '<leader>ggf', "Telescope git_signs", '[gg]it [f]ind signs', 'TelescopeGitSigns', },
    },
    config = function ()
      require'telescope'.load_extension 'git_signs'
    end
  },

  --- add signs in left column based on git status
  { 'lewis6991/gitsigns.nvim',
    cmd = 'Gitsigns',
    opts = {
      -- See `:help gitsigns.txt`
      numhl = true,
      linehl = true,
      -- word_diff = true,
      preview_config = {
        border = "rounded"
      },
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      -- on_attach = function(bufnr)
      --   vim.keymap.set('n', '<leader>gk', require('gitsigns').prev_hunk, { buffer = bufnr, desc = '[G]o to [P]revious Hunk' })
      --   vim.keymap.set('n', '<leader>gj', require('gitsigns').next_hunk, { buffer = bufnr, desc = '[G]o to [N]ext Hunk' })
      --   vim.keymap.set('n', '<leader>ph', require('gitsigns').preview_hunk, { buffer = bufnr, desc = '[P]review [H]unk' })
      -- end,
    },
    keycommands_meta = {
      group_name = 'Git Signs',
      description = 'Control git in buffer',
      icon = '',
    },
    keycommands = {
      { '[g', 'Gitsigns prev_hunk wrap=false', 'Git Hunk previous', },
      { ']g', 'Gitsigns next_hunk wrap=false', 'Git Hunk last', },

      { '<leader>ggp', 'Gitsigns preview_hunk', '[gg]it [p]review hunk', },
      { '<leader>ggs', 'Gitsigns stage_hunk', '[gg]it [s]tage hunk', },
      { '<leader>ggs', function()
        require'gitsigns'.stage_hunk {vim.fn.line('.'), vim.fn.line('v')}
      end, '[gg]it [s]tage hunk (visual)', mode = 'v' },
      { '<leader>ggS', 'Gitsigns stage_buffer', '[gg]it [S]tage whole buffer', },
      { '<leader>ggu', 'Gitsigns undo_stage_hunk', '[gg]it [u]nstage hunk', },
      { '<leader>ggu', function()
        require'gitsigns'.unstage_hunk {vim.fn.line('.'), vim.fn.line('v')}
      end, '[gg]it [u]nstage hunk (visual)', mode = 'v' },
      { '<leader>ggU', 'Gitsigns undo_stage_buffer', '[gg]it [U]nstage whole buffer', },
      { '<leader>ggd', 'Gitsigns toggle_deleted', '[gg]it [U]nstage whole buffer', },
      { '<leader>ggh', 'Gitsigns toggle_linehl', '[gg]it toggle line [h]ighlights', },
      { '<leader>ggb', 'Gitsigns blame_line', '[gg]it toggle [b]lame line', },
      { '<leader>ggq', 'Gitsigns setqflist', '[gg]it open [q]uickfix list of hunks', },

      { '<leader>ggts', 'Gitsigns toggle_signs', '[gg]it [t]oggle signs in column', },
      { '<leader>ggtb', 'Gitsigns toggle_current_line_blame', '[gg]it [t]oggle current line [b]lame', },
      { '<leader>ggtn', 'Gitsigns toggle_numhl', '[gg]it [t]oggle numbers in column', },
      { '<leader>ggtw', 'Gitsigns toggle_word_diff', '[gg]it [t]oggle word diff', },

      { '<leader>ggla', 'Gitsigns get_actions', '[gg]it [l]ist [a]ctions', },

      { '<leader>ggrb', 'Gitsigns reset_buffer_index', "[gg]it [r]eset buffer, doesn't undo stages", },
      { '<leader>ggrB', 'Gitsigns reset_buffer', '[gg]it [r]eset [B]uffer (all hunks)', },
      { '<leader>ggri', 'Gitsigns reset_base', '[gg]it [r]eset base [i]ndex for diffs', },
      { '<leader>ggrh', 'Gitsigns reset_hunk', '[gg]it [r]eset [h]unk', },

      { '<leader>gguh', 'Gitsigns undo_stage_hunk', '[gg]it [u]ndo stage [h]unk', },
    },
  },

  --- Great Diff/Merge viewer
  -- maybe add `git config --global merge.tool nvimdiff` ?
  { 'sindrets/diffview.nvim',
    keycommands_meta = {
      group_name = 'Git Diff',
      description = 'Diffview for merging/diffing/rebasing',
      icon = '',
    },
    keycommands = {
      { '<leader>gdv', 'DiffviewOpen', 'open [g]it [d]iff [v]iew', 'Diffview' },
      { '<leader>gdc', 'DiffviewClose', '[g]it [d]iff view [c]lose', 'DiffviewClose' },
      { '<leader>gda', 'DiffviewFileHistory', '[g]it [d]iff view file history', 'DiffViewFile' },
      { '<leader>gdd', 'DiffviewFileHistory %', '[g]it [dd]iff view file history on current buffer', 'DiffviewFileCurrent' },
      { '<leader>gds', 'DiffviewFileHistory -g --range=stash', '[g]it [d]iff view file history on [s]tash', 'DiffviewStash' },
      {
        '<leader>gdD',
        [['<,'>DiffviewFileHistory]],
        '[g]it [d]iff view file history on [s]tash',
        'DiffviewFileSelection',
        mode = 'v',
      },
    },
    opts = {
      enhanced_diff_hl = true,
      view = {
        default = {
          layout = "diff2_vertical",
          winbar_info = true,
        },
        merge_tool = {
          layout = "diff3_mixed",
        },
        file_history = {
          layout = "diff2_vertical",
          winbar_info = true,
        },
      },
      keymaps = {
        file_panel = {
          { 'n', '<leader>q', '<cmd>DiffviewClose<cr>', { desc = 'Close GitdiffView' } }
        },
        file_history_panel = {
          { 'n', '<leader>q', '<cmd>DiffviewClose<cr>', { desc = 'Close GitdiffView' } }
        },
      }
    }
  },

  -- new replacement for fugitive
  { 'neogitorg/neogit',
    dependencies = {
      "nvim-lua/plenary.nvim",         -- required
      "nvim-telescope/telescope.nvim", -- optional
      "sindrets/diffview.nvim",        -- optional
      "ibhagwan/fzf-lua",              -- optional
    },
    opts = {
      signs = {
        -- { CLOSED, OPENED }
        section = { "", "" },
        item = { "", "" },
        hunk = { "", "" },
      },
      integrations = { diffview = true }
    }
  },

  { 'tpope/vim-fugitive',
    cond = vim.fn.executable("git") == 1,
    cmd = {
      "G",
      "Git",
      "Ggrep",
      "Glgrep",
      "Gclog",
      "Gllog",
      "Gcd",
      "Glcd",
      "Gedit",
      "Gvsplit",
      "Gtabedit",
      "Gpedit",
      "Gdrop",
      "Gread",
      "Gwrite",
      "Gwq",
      "Gdiffsplit",
      "Ghdiffsplit",
      "GMove",
      "GRename",
      "GDelete",
      "GRemove",
      "GUnlink",
      "GBrowse",
    },
    keycommands_meta = {
      group_name = 'Git',
      description = 'Git Operations (general)',
      icon = '',
      default_opts = { -- only applies to this lazy keygroup
        silent = true,
      }
    },
    keycommands = {
      -- Telescope Git
      { '<leader>gfa', "Telescope git_commits", '[g]it [f]ind [a] commits', 'TelescopeGitCommits' },
      { '<leader>gfb', "Telescope git_branches", '[g]it [f]ind [b]ranches', 'TelescopeGitBranches' },
      { '<leader>gfc', "Telescope git_bcommits", '[g]it [f]ind [c]ommits', 'TelescopeGitBranchCommits' },
      { '<leader>gff', "Telescope git_files", '[g]it [f]ind [f]iles', 'TelescopeGitFiles' },

      -- browse
      { "<leader>ggg", 'Neogit', 'Open Neogit', },
      { "<leader>gs", 'Git', '[g]it [s]tatus', },
      { "<leader>gb", 'Git blame', '[g]it open [b]lame list', },
      { "<leader>gB", 'GBrowse', '[g]it [B]rowse (open in a browser)', },
      { "<leader>gq", '0Gclog', '[g]it open commit log in [q]uickfix list for current buffer', },
      { "<leader>gQ", 'Gclog', '[g]it open commit log in [Q]uickfix list', },

      -- commit/stage
      { "<leader>gc", 'Git commit -v -q', '[g]it [c]ommit', },
      { "<leader>gC", 'Git commit -v -q --amend', '[g]it [C]ommit + amend', },
      { "<leader>gw", 'Gwrite', '[g]it [w]rite + stage current file', },
      { "<leader>gm", 'Git merge', '[g]it [m]erge', },

      -- diffs
      { "<leader>gdd", 'Gdiff', '[g]it [dd]iff to staged', },
      { "<leader>gdh", 'Gdiff HEAD', '[g]it [d]iff to last commit on [h]ead (HEAD branch)', },
      { "<leader>gdo", 'Gdiff origin/HEAD', '[g]it [d]iff to last commit on [o]rigin/HEAD', },

      -- hunks
      -- map('n', '<leader>ga', ':GitGutterStageHunk<cr>', { desc = '[a]: Gutter Stage Hunk' })
      -- map('n', '<leader>gj', ':GitGutterNextHunk<cr>', { desc = '[j]: Go to next hunk' })
      -- map('n', '<leader>gk', ':GitGutterPrevHunk<cr>', { desc = '[k]: Go to prev hunk' })
      -- map('n', '<leader>gu', ':GitGutterUndoHunk<cr>', { desc = 'Gutter [u]ndo Hunk' })

      -- push/pull
      { "<leader>gpp", 'Git pull', '[g]it [pp]ull', },
      { "<leader>gpP", 'Git push', '[g]it [pP]ush', },
      { "<leader>gpo", 'Git pull origin', '[g]it [p]ull from [o]rigin', },
      { "<leader>gpO", 'Git push origin', '[g]it [p]ush to [O]rigin', },
      { "<leader>gpu", 'Git pull upstream', '[g]it [p]ull from [u]pstream', },
      { "<leader>gpU", 'Git push upstream', '[g]it [p]ush to [U]pstream', },
      { "<leader>gpf", function ()
         vim.cmd("Git push -u origin "..GitCurrentBranchName())
      end, '[g]it [p]ush to origin for [f]irst time', },
    }
  },
}
