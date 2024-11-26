# Fancy vim menus for ':', ':', '/', '?'
# allows fuzzy searching terms better
{ pkgs, ... }:
let
  cmd = command: desc: [
    "<cmd>${command}<cr>"
    desc
  ];
in
{
  plugins = [
    pkgs.vimPlugins.nvim-luadev # repl / output of lua
    pkgs.vimPlugins.codi-vim # general repl for python / lua + more
    pkgs.vimPlugins.neodev-nvim # docs + completions for lua vim api
  ];

  nmap."<leader>rr" = "<Plug>(Luadev-RunLine)";
  vmap."<leader>rr" = "<Plug>(Luadev-Run)";
  # worse than neodev
  # imap."<leader>rr" = "<Plug>(Luadev-Complete)";

  lua = builtins.readFile ./neodev.lua;
  #_internal.which-key.codi = {
  #  "['<leader>']" = {
  #    # Telescope
  #    #r.r = [ "<Plug>(Luadev-Run)" "Run selected in LuaDev" ];
  #    f = {
  #      name = "+telescope";
  #      a = cmd "Telescope git_commits" "All Commits";
  #      j = cmd "Telescope current_buffer_fuzzy_find" "Fuzzy search in current buffer";
  #      c = cmd "Telescope git_branches" "Git Branches";
  #      C = cmd "Telescope git_bcommits" "Commits since last fork";
  #      s = cmd "Telescope git_status" "Git Status";
  #      g = cmd "Telescope live_grep" "Fuzzy search in working dir";
  #      e = cmd "Telescope diagnostics" "Errors / Diagnostics";
  #      d = cmd "Telescope lsp_document_symbols" "lsp document symbols";
  #      f = cmd "Telescope find_files" "Search files";
  #      F = cmd
  #        "lua require'telescope.builtin'.live_grep {default_text='function'}"
  #        "grep for functions only"
  #      ;
  #      r = cmd "Telescope resume" "last telescope query";
  #      p = cmd "Telescope project" "telescope project";
  #      t = cmd "Telescope " "Telescope default";
  #      h = cmd "Telescope command_history" "Telescope command history";
  #      m = cmd "Telescope keymaps" "Telescope mapped key bindings";
  #      q = cmd "Telescope quickfix" "Telescope quickfix list";
  #      "[':']" = cmd "Telescope commands" "Telescope command picker";
  #      "['-']" = cmd "Telescope file_browser" "Get buffer list";
  #      "[';']" = cmd "Telescope command_history" "Telescope command history";
  #      "['~']" = cmd
  #        "lua require'telescope.builtin'.find_files({ search_dirs={'~'} })"
  #        "Search files in home directory"
  #      ;
  #      "['.']" = cmd
  #        "lua require'telescope.builtin'.find_files({ search_dirs={getCurrDir()} })"
  #        "Search files in home directory"
  #      ;
  #    };
  #  };
  #};
}
