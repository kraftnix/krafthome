# Telescope is a picker/searcher framework
# - fuzzy search like FZF with nicer UIs
# - integrations with Git, Vim Internal Info, LSP and more
# - can write custom pickers
{
  pkgs,
  dsl,
  ...
}: let
  cmd = command: desc: ["<cmd>${command}<cr>" desc];
in
  with dsl; {
    plugins = with pkgs.vimPlugins; [
      # fuzzy finder
      plenary-nvim
      telescope-nvim
      telescope-fzf-native-nvim
      telescope-file-browser-nvim
      telescope-manix # nix manix search

      sqlite-lua # req for cheatsheet
      telescope-cheat-nvim # cheatsheet search

      telescope-tabs
      telescope-all-recent
      telescope-env
      telescope-undo
      telescope-changes
      tabline-nvim

      # sexy dropdown
      telescope-ui-select-nvim
      nvim-telescope-hop
    ];

    lua = builtins.readFile ./telescope.lua;
    _internal.which-key.telescope = {
      "['<leader>']" = {
        # Telescope
        w.w = cmd "Telescope buffers" "Get buffer list";
        f = {
          name = "+telescope";
          a = cmd "Telescope git_commits" "All Commits";
          j = cmd "Telescope current_buffer_fuzzy_find" "Fuzzy search in current buffer";
          J = cmd "lua require'telescope.builtin'.live_grep{ search_dirs={\"%:p\"} }" "Fuzzy search in current directory";
          c = cmd "Telescope git_branches" "Git Branches";
          C = cmd "Telescope git_bcommits" "Commits since last fork";
          s = cmd "Telescope git_status" "Git Status";
          g = cmd "Telescope live_grep" "Fuzzy search in working dir";
          G = cmd "Telescope grep_string" "Fuzzy search your cursor";
          e = cmd "Telescope diagnostics" "Errors / Diagnostics";
          E = cmd "Telescope env" "lookup undo tree";
          d = cmd "Telescope lsp_document_symbols" "lsp document symbols";
          f = cmd "Telescope find_files" "Search files";
          F =
            cmd
            "lua require'telescope.builtin'.live_grep {default_text='function'}"
            "grep for functions only";
          r = cmd "Telescope resume" "last telescope query";
          p = cmd "Telescope project" "telescope project";
          t = cmd "Telescope " "Telescope default";
          T = cmd "Telescope telescope-tabs list_tabs" "Telescope list tabs";
          h = cmd "Telescope command_history" "Telescope command history";
          m = cmd "Telescope keymaps" "Telescope mapped key bindings";
          #n = cmd "Telescope manix" "manix search for selected word";
          n = cmd "lua require'telescope-manix'.search({ cword = true })" "manix search for selected word";
          N = cmd "lua require'telescope-manix'.search({ cword = false })" "manix search (general)";
          q = cmd "Telescope quickfix" "Telescope quickfix list";
          "[':']" = cmd "Telescope commands" "Telescope command picker";
          "['-']" = cmd "Telescope file_browser" "Get buffer list";
          "[';']" = cmd "Telescope command_history" "Telescope command history";
          "['~']" =
            cmd
            "lua require'telescope.builtin'.find_files({ search_dirs={'~'} })"
            "Search files in home directory";
          "['.']" =
            cmd
            "lua require'telescope.builtin'.find_files({ search_dirs={getCurrDir()} })"
            "Search files in home directory";
          u = cmd "Telescope undo" "lookup undo tree";
          z = cmd "Telescope cheat fd" "lookup cheatsheets";
        };
      };
    };
    #''
    #  require("telescope").setup {
    #    defaults = {
    #      file_ignore_patterns = { "node_modules", "target" },
    #      prompt_prefix = "   ",
    #      selection_caret = "  ",
    #      entry_prefix = "  ",
    #      borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
    #      vimgrep_arguments = {
    #        "${pkgs.ripgrep}/bin/rg",
    #        "--color=never",
    #        "--no-heading",
    #        "--with-filename",
    #        "--line-number",
    #        "--column",
    #        "--smart-case",
    #      },
    #    },
    #    extensions = {
    #      ["ui-select"] = {
    #        require("telescope.themes").get_dropdown {
    #          -- even more opts
    #        }
    #      }
    #    }
    #  }
    #  require("telescope").load_extension("file_browser")
    #  require("telescope").load_extension("ui-select")
    #'';
  }
