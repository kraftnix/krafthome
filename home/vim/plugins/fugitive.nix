# Git in vim plugin from tpope
{
  pkgs,
  dsl,
  ...
}:
with dsl;
let
  cmd = command: desc: [
    "<cmd>${command}<cr>"
    desc
  ];
in
{
  plugins = with pkgs.vimPlugins; [
    vim-fugitive
    vim-gitgutter
  ];
  lua = ''
    function GitCurrentBranchName()
      local branch = vim.fn.system("git branch --show-current 2> /dev/null | tr -d 'n'")
      if branch ~= "" then
        return branch
      else
        return ""
      end
    end
  '';
  _internal.which-key.fugitive = {
    "['<leader>']" = {
      g = {
        name = "+fugitive";
        # Status
        g = [
          ":Git "
          "Open git command"
        ];
        s = cmd "Git" "Git Status";

        # Operations
        # - File Ops
        w = cmd "Gwrite" "Write + stage current file";
        c = cmd "Git commit -v -q" "Commit";
        C = cmd "Git commit -v -q --amend" "Commit + amend";
        b = cmd "Git blame" "Git Blame";
        # - hunk operations
        a = cmd "GitGutterStageHunk" "Gutter Stage Hunk";
        u = cmd "GitGutterUndoHunk" "Gutter Undo Hunk";
        j = cmd "GitGutterNextHunk" "Go to next hunk";
        k = cmd "GitGutterPrevHunk" "Go to prev hunk";

        # Diffs
        d = {
          name = "+diffs";
          d = cmd "Gdiff" "Diff to staged";
          h = cmd "Gdiff HEAD" "Diff to last commit on current file";
          o = cmd "Gdiff origin/HEAD" "Diff to origin HEAD";
          g = [
            ":Gdiff "
            "Git diff (select your branch)"
          ];
        };

        # Remote / Branching
        r = [
          ":Git rebase --interactive<Space>"
          "Interactive rebase"
        ];
        R = [
          ":Git rebase "
          "Open rebase command"
        ];
        o = [
          ":Git checkout "
          "Open Checkout command"
        ];
        O = [
          ":Git branch "
          "Open Branch command"
        ];
        q = cmd "0Gclog" "Open current file commit log quickfix list";
        Q = cmd "Gclog" "Open all commits log into quickfix list";
        m = [
          ":Git merge "
          "Git merge"
        ];
        B = cmd "GBrowse" "Open file in GitHub";
        p = {
          name = "+Remote options (push/pull)";
          p = cmd "Git pull" "Pull";
          P = cmd "Git push" "Push";
          u = [
            ":Git pull upstream "
            "Pull upstream (complete)"
          ];
          U = [
            ":Git push upstream "
            "Push upstream (complete)"
          ];
          o = [
            ":Git pull origin "
            "Pull origin (complete)"
          ];
          O = [
            ":Git push origin "
            "Push origin (complete)"
          ];
          f = [
            "<CMD>lua vim.cmd('Git push -u origin '..GitCurrentBranchName())<CR>"
            "Push origin for first time, same name"
          ];
        };
      };
    };
  };
}
