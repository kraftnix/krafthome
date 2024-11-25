# Essential Configuration
{
  lib,
  config,
  pkgs,
  dsl,
  ...
}:
with dsl; let
  cmd = command: desc: ["<cmd>${command}<cr>" desc];
in {
  plugins = with pkgs.vimPlugins; [
    # command discover
    which-key-nvim
    # for sane tab detection
    nvim-guess-indent

    vim-oscyank # copy anywhere

    undotree # view all undo/repo operations
    vim-unimpaired # movements options with [
    vim-vsnip # snippets
    #friendly-snippets # more snippets
    vim-togglelist # toggle location + quickfix lists
    sessions-nvim # make / save / load session files

    deoplete-nvim # async operations (dependency)
    nvim-yarp # dependency for deoplete

    suda-vim # read/write files with sudo

    surround-nvim
    nvim-autopairs
  ];

  setup.surround = {};
  use.nvim-autopairs.setup = callWith {};
  use.sessions.setup = callWith {};

  set = {
    autoread = true;

    # tab options
    expandtab = true;
    shiftwidth = 2;
    smartindent = true;
    softtabstop = 2;
    tabstop = 2;
  };

  lua = lib.mkBefore ''
    function strEmpty(s)
      return s == nil or s == ""
    end
    function getCurrDir()
      file = vim.fn.expand("%")
      if strEmpty(file) then
        return vim.fn.getcwd()
      else
        return vim.fn.system("dirname "..file):gsub("%s+", "")
      end
    end
  '';

  vim.g = {
    mapleader = " ";
    nofoldenable = true;
    noshowmode = true;
    completeopt = "menu,menuone,noselect";
    noswapfile = true;
    blamer_enabled = 1;
    oscyank_max_length = 100000000;
  };

  vim.o = {
    grepprg = "rg --vimgrep --no-heading --smart-case";
    grepformat = "%f:%l:%c:%m,%f:%l:%m";
    showcmd = true;
    showmatch = true;
    ignorecase = true;
    smartcase = true;
    cursorline = true;
    wrap = true;
    autoindent = true;
    copyindent = true;
    splitbelow = false;
    splitright = true;
    number = true;
    relativenumber = true;
    title = true;
    undofile = true;
    autoread = true;
    hidden = true;
    list = true;
    background = "dark";
    backspace = "indent,eol,start";
    undolevels = 1000000;
    undoreload = 1000000;
    foldmethod = "indent";
    foldnestmax = 10;
    foldlevel = 1;
    scrolloff = 3;
    sidescrolloff = 5;
    listchars = "tab:→→,trail:●,nbsp:○";
    clipboard = "unnamed,unnamedplus";
    formatoptions = "tcqj";
    encoding = "utf-8";
    fileencoding = "utf-8";
    fileencodings = "utf-8";
    bomb = true;
    binary = true;
    matchpairs = "(:),{:},[:],<:>";
    expandtab = true;
    #pastetoggle = "<leader>v";
    wildmode = "list:longest,list:full";
  };

  cmap."w!!" = ":SudaWrite<CR>";
  tnoremap = {
    # NOTE: these are double escaped through nix, then lua
    # Remap escape visual mode to escape
    "<Esc>" = "<C-\\\\><C-n>";
    # Remap escape passthrough to <C-\><C-n>
    "<C-\\\\><C-n>" = "<Esc>";
    "<C-S>" = "<C-\\\\><C-n> :ToggleTerm<cr>";
    #"<C-S>" = ":ToggleTerm<cr>";
  };

  vnoremap = {
    "<Leader>y" = ":OSCYankVisual<CR>";
  };
  nnoremap = {
    "<Leader>Y" = "v$:OSCYankVisual<CR>";
    "<Leader>yy" = "V:OSCYankVisual<CR>";
  };

  use.which-key.register = dsl.callWith (lib.foldl' lib.recursiveUpdate
    {
      L = rawLua ''{ "<cmd>tabn<cr>", "Go to next tab", noremap = true }'';
      H = rawLua ''{ "<cmd>tabp<cr>", "Go to prev tab", noremap = true }'';
      j = ["gj" "Wrapped down"];
      k = ["gk" "Wrapped up"];
      "[']']" = {
        name = "+Jump next";
        d = cmd "lua vim.diagnostic.goto_next()" "next diag";
        q = cmd "cnext" "next quickfix";
      };
      "['[']" = {
        name = "+Jump prev";
        d = cmd "lua vim.diagnostic.goto_prev()" "prev diag";
        q = cmd "cprev" "prev quickfix";
      };
      "['<leader>']" = {
        name = "+leader_bindings";

        ai = cmd "AnsiEsc" "Replace ansi escape codes with colors";
        a = {
          name = "+misc commands";
          t = cmd "NvimTreeToggle" "Toggle NvimTree";
        };

        r = {
          name = "+run";
          c = cmd "r!" "run a command, pipe output into buffer";
          C = cmd "!" "run a command";
        };

        ok = cmd "WhichKey" "Start WhichKey";

        u = cmd "UndotreeToggle" "Toggle UndoTree";

        # movement
        #"'.'" = cmd ":<Up><CR>" "Repeat last command";
        j = cmd "wincmd j" "Move cursor to buffer below";
        k = cmd "wincmd k" "Move cursor to buffer above";
        l = cmd "wincmd l" "Move cursor to buffer right";
        h = cmd "wincmd h" "Move cursor to buffer left";
        J = cmd "wincmd J" "Move buffer downwards";
        K = cmd "wincmd K" "Move buffer upwards";
        L = cmd "wincmd L" "Move buffer right";
        H = cmd "wincmd H" "Move buffer left";

        w = {
          name = "+window operations";
          x = cmd "sp" "Split window horizontally";
          v = cmd "vs" "Split window vertically";
          q = cmd "q" "Close buffer";
          d = cmd "bd" "Delete buffer";
          k = cmd "bnext" "Next buffer";
          j = cmd "bprev" "Previous buffer";
          t = cmd "tabedit" "New buffer/tab";
          D = cmd "Bclose!" "Delete buffer aggressively";
        };
        #"gs" =
        #  [ "<cmd>lua require('neogit').open()<CR>" "Open neogit (magit clone)" ];
        #"gb" = [ "<cmd>BlamerToggle<CR>" "Toggle git blame" ];
        #"gc" = [ "<cmd>Neogen<CR>" "generate comments boilerplate" ];

        #"hs" = [ "<cmd>Gitsigns preview_hunk<CR>" "preview hunk" ];
        #"hn" = [ "<cmd>Gitsigns next_hunk<CR>" "next hunk" ];
        #"hp" = [ "<cmd>Gitsigns prev_hunk<CR>" "prev hunk" ];
        "gi" = ["<cmd>GuessIndent<CR>" "guess indent again"];

        # CD
        "cg" = ["<cmd>Gcd<CR>" "change directory to parent .git dir"];
        "cl" = ["<cmd>lcd %:h<CR>" "change directory to current file dir"];
        "ch" = ["<cmd>cd \~<CR>" "change directory to home dir"];
        "['c.']" = ["<cmd>Cd .<CR>" "change directory to current dir"];
        "['c<space>']" = [":Cd" "something"];
      };
    }
    (lib.attrValues config._internal.which-key));
  use.which-key.setup = callWith {};

  use.guess-indent.setup = callWith {};

  # yoinked from gytis
  vimscript = ''
    " Function to clean trailing Spaces on save
    function! CleanExtraSpaces() "Function to clean unwanted spaces
        let save_cursor = getpos(".")
        let old_query = getreg('/')
        silent! %s/\s\+$//e
        call setpos('.', save_cursor)
        call setreg('/', old_query)
    endfun
    autocmd BufWritePre * :call CleanExtraSpaces()
    " Preserve cursor location
    autocmd BufReadPost *
      \ if line("'\"") >= 1 && line("'\"") <= line("$") |
      \   exe "normal! g`\"" |
      \ endif
  '';
}
