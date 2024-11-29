{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib)
    concatStringsSep
    mkMerge
    mapAttrsToList
    ;

  # colors
  # inherit (config.lib) base16;
  # colorName = "base16-${base16.theme.scheme-slug}";
  fullNvimTreesitter =
    (pkgs.vimPlugins.nvim-treesitter.overrideAttrs (
      oldAttrs:
      oldAttrs
      // {
        # tree-sitter = pkgs.tree-sitter-with-nu;
        tree-sitter = pkgs.tree-sitter-full;
      }
    )).withAllGrammars;
in
# fullNvimTreesitter = pkgs.channels.stable.vimPlugins.nvim-treesitter;
# fullNvimTreesitter = pkgs.vimPlugins.nvim-treesitter;
{
  home.packages = [ pkgs.zk ];
  home.sessionVariables."ZK_NOTEBOOK_DIR" = lib.mkDefault "/home/$USER/notes";
  # home.activation.neovim-copy = lib.mkForce (lib.hm.dag.entryBetween [ "reloadSystemd" ] [ ] "");
  programs.lazy-neovim = {
    enable = lib.mkForce true;
    sourceDir = ./src;
    extraPackages = with pkgs; [
      lua-language-server
      nil
      nixd
      gopls
      nodePackages.bash-language-server
      pyright
      nodePackages.yaml-language-server
      nodePackages.dockerfile-language-server-nodejs
      docker-compose-language-service
      zk
    ];
    plugins = with pkgs.vimPlugins; [
      ## Core
      lazy-nvim # plugin manager

      # Movement / buffer mgmt
      treesj # fancy split/join of TS objects
      nvim-autopairs # pair up brackets/quotes etc.
      # nvim-surround       # easily change pairs (i.e. "" -> '')
      flash-nvim # jump around with f,t,s
      harpoon # mark buffers and jump between them
      portal-nvim # jump around lists with keys
      neoscroll-nvim # animated/speed scrolling (laggy over SSH tho)
      nvim-surround # autopairs ()[]<>{} completion (with treesitter magic)

      ## LSP
      nvim-lspconfig # configure LSPs
      neodev-nvim # configure lua + neovim projects
      nvim-nu # old-school null-ls nushell LSP
      none-ls-nvim # none-ls (language agnostic LSP)
      lsp_signature-nvim # LSP Signature Info (old, noice instead)
      lspkind-nvim # LSP Icons (can use in cmp)
      lspsaga-nvim # LSP extra functions
      trouble-nvim # LSP extra functions
      nvim-luadev # repl you can run in neovim for lua code
      vim-doge # documentation generation (lua)
      neogen # better annotation generation
      nvim-devdocs # open devdocs.io from vim

      ## cmp + snippets
      nvim-cmp # core
      cmp-nvim-lsp # lsp completions
      cmp-cmdline # wilder equiv
      cmp-cmdline-history # include history of commands/searchs
      cmp-buffer # buffer sources
      cmp-path # path sources
      cmp-async-path # path (async) sources
      cmp-treesitter # treesitter sources
      cmp-rg # rg source, searches well across buffers
      cmp-under-comparator # lowers priority of __ in completions (comparator)
      cmp_luasnip # complete luasnip snippets in cmp (source)
      luasnip # luasnip snippets
      sniprun # run snippets with a binding (lua + rust)
      friendly-snippets # extra snippet source
      wilder-nvim # cmdline/search completion (use cmp now)
      cpsm # wilder dependency

      ## Dap
      nvim-dap # Debug Adapter Protocol
      nvim-dap-ui # nui based ui for DAP
      nvim-nio # required by nvim-dap-ui
      nvim-dap-virtual-text # UI / Highlight for DAP virtual text
      one-small-step-for-vimkind-nvim # lua dap adapter
      telescope-dap-nvim # telescope picker for DAP
      nvim-dap-python # python dap adapter

      # Lists
      vim-togglelist # simple, add vim commands for toggle quickfix/loclist TODO: replace
      nvim-bqf # better quick fix list, has a hover TODO: replace with trouble

      ## UI
      lualine-nvim # status/tabline
      dressing-nvim # pretty/glossy vim.ui.{select|input}
      nvim-web-devicons # nerd fonts for nvim
      nvim-colorizer-lua # highlight hex codes with their colour
      noice-nvim # meta UI plugin, message routing, lsp, cmdline, etc.
      nui-nvim # UI library (noice + dap-ui)
      nvim-notify # notification handler (used by noice)
      tabline-nvim # tabline (old, replaced by lualine)
      zen-mode-nvim # remove distractions
      tokyonight-nvim # nice theme
      urlview-nvim # picker (ui.select support) for URLs

      ## Lib
      plenary-nvim # toolbox/lib for many libs
      middleclass-nvim # smarter class implementation

      ## Keys
      which-key-nvim # popups for key combos
      legendary-nvim # cmd/keymapper with a picker
      commander-nvim # another cmd/keymapper with a picker

      ## Tools
      glow-nvim # markdown preview
      zk-nvim # zk knowledge base lsp
      nvim-neoclip-lua # clipboard/macro manager

      ## File Manager
      fm-nvim # generic file manager for cli tools (ranger)
      oil-nvim # nvim file manager in buffer
      neo-tree-nvim # tree-based file structure in side panel
      yazi-nvim # integrate yazi + nvim

      # Find-replace
      ssr-nvim # treesitter-based structural search
      inc-rename-nvim # incremental rename
      nvim-spectre # hardcore find replace

      ## Git
      vim-fugitive # tpope git core plugin
      gitlinker-nvim # open/copy external git forge links (GBrowse replacement)
      gitsigns-nvim # git signs in the columns
      diffview-nvim # Diif/Merge view UI
      neogit # new Magit based Git UI

      ## General
      mini-nvim # mini tools (lots of things)
      fzf-vim # another fuzzy search tool/picker
      fzf-lua # another fuzzy search tool/picker
      pkgs.fzf # for above
      dial-nvim # smart increment/decrement
      comment-nvim # comments with easy motion
      todo-comments-nvim # highlight comments
      sqlite-lua # sqlite API (used by other plugins)
      vim-oscyank # yank out of neovim through ssh/tmux with OSC52 escape
      vim-suda # sudo write file with w!!
      vim-sleuth # detect tabstop and shiftwidth automatically

      ## Terminal
      toggleterm-nvim # toggle terminals in floating windows (old)
      terminal-nvim # toggle terminals

      ## Telescope
      telescope-nvim # picker
      telescope-fzf-native-nvim # use fzf-native for faster search
      telescope-file-browser-nvim # file browser
      telescope-live-grep-args-nvim # use rg for search
      telescope-manix # nix manix manual search
      telescope-cheat-nvim # cheatsheet (cheat.sh)
      telescope-tabs # tabs
      telescope-env # host ENV vars
      telescope-zoxide # lookup and use host zoxide
      telescope-menufacture # nice submenus in some core builtins
      telescope-all-recent # frecency sorting for telescope pickers
      telescope-project-nvim # search git repos in your home dir + cwd to them
      telescope-undo # undo history
      telescope-lazy-nvim # lazy plugins searcher (includes code search, reload, etc.)
      telescope-changes # changelist history (vendored)
      telescope-luasnip # luasnip snippet lookup + use
      telescope-lsp-handlers-nvim # lsp handlers integration
      browser-bookmarks-nvim # firefox browser lookup
      easypick-nvim # quickly make telescope pickers for external cli calls
      telescope-ui-select-nvim # use telescope for autocomplete

      ## Treesitter
      nvim-treesitter-textobjects # move/swap/peek/select objects
      nvim-treesitter-textsubjects # select textsubjects up/down
      nvim-treesitter-context # conceals top part of screen in deeply nested code
      nvim-treesitter-refactor # smart rename (current scope) + highlight scope + backup go to def/ref
      nvim-ts-context-commentstring # add commentstring context to treesitter
      rainbow-delimiters-nvim # fancy rainbow brackets
      playground
      # fullNvimTreesitter
      pkgs.nvim-treesitter-full
      # "nvim-treesitter" = nvim-treesitter.withAllGrammars;
      # workaround required for using nvim-treesitter with `lazy.nvim`
      # (pkgs.stdenv.mkDerivation {
      #   name = "nvim-treesitter-parsers";
      #   pname = "nvim-treesitter-parsers";
      #   src = hostPkgs.tree-sitter-full.grammarPlugins.ada;
      #   buildPhase = ''
      #     mkdir -p $out/parser
      #     ${concatStringsSep "\n" (mapAttrsToList
      #       (name: pkg:
      #         "cp ${pkg}/parser/* $out/parser"
      #       ) hostPkgs.tree-sitter-full.grammarPlugins)
      #     }
      #   '';
      # })
    ];
  };
  xdg.configFile = mkMerge [
    {
      # ".config/nvim/colors/${colorName}.vim".source = vimColors.template "vim";
      # ".config/nvim/autoload/airline-${colorName}.vim".source = base16.getTemplate "vim-airline-themes";
      # ".config/nvim/parser/nu.so".source = "${pkgs.tree-sitter-full.builtGrammars.tree-sitter-nu}/parser";
      "nvim/parser".source = pkgs.tree-sitter-parsers;
    }
  ];
}
