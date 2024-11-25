# LSP + Language specific configurations
{
  pkgs,
  dsl,
  ...
}: let
  cmd = command: desc: ["<cmd>${command}<cr>" desc];
in
  with dsl; {
    plugins = with pkgs.vimPlugins; [
      null-ls-nvim # configurable LSP for unsupported languages
      nvim-lspconfig # collection of LSP config files
      lspsaga-nvim # extra UI for lsp

      # Languages
      nvim-nu # nushell
      vim-nix # nix
      pkgs.nil
      pkgs.lua-language-server
    ];

    # moved into whichkey
    lua = builtins.readFile ./lsp.lua;

    # Lua
    use.lspconfig.lua_ls.setup = callWith {
      on_attach = rawLua "on_attach";
      cmd = ["${pkgs.lua-language-server}/bin/lua-language-server"];
      settings.Lua = {
        diagnostics.globals = ["vim"];
        workspace = {
          library = rawLua ''            {
                      vim.fn.expand "$VIMRUNTIME",
                      --get_lvim_base_dir(),
                      require("neodev.config").types(),
                      "''${3rd}/busted/library",
                      "''${3rd}/luassert/library",
                    }'';
          maxPreload = 5000;
          preloadFileSize = 10000;
          # Stops LSP asking about work environment constantly
          checkThirdParty = false;
        };
        telemetry.enable = false;
      };
    };

    # Bash
    use.lspconfig.bashls.setup = callWith {
      on_attach = rawLua "on_attach";
      cmd = ["${pkgs.nodePackages.bash-language-server}/bin/bash-language-server"];
    };

    # Python
    use.lspconfig.pyright.setup = callWith {
      on_attach = rawLua "on_attach";
      cmd = ["${pkgs.pyright}/bin/pyright"];
    };

    # Go
    use.lspconfig.gopls.setup = callWith {
      cmd = ["${pkgs.gopls}/bin/gopls"];
    };

    # NOTE: moved to ./lsp.lua
    # Nushell
    #use.lspconfig.nu.setup = callWith {
    #  on_attach = rawLua "on_attach";
    #  use_lsp_features = true;
    #  all_cmd_names = rawLua "[[nu -c 'help commands | get name | str join \"\\n\"']]";
    #};

    # Nix
    #use.lspconfig.rnix.setup = callWith {
    #  on_attach = rawLua "on_attach";
    #  cmd = [ "${pkgs.rnix-lsp}/bin/rnix-lsp" ];
    #  capabilities = rawLua "require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())";
    #};

    # Nix
    use.lspconfig.nil_ls.setup = callWith {
      on_attach = rawLua "on_attach";
      cmd = ["${pkgs.nil}/bin/nil"];
      capabilities = rawLua "require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())";
    };

    # Rust
    use.lspconfig.rust_analyzer.setup = callWith {
      on_attach = rawLua "on_attach";
      cmd = ["${pkgs.rust-analyzer}/bin/rust-analyzer"];
      capabilities = rawLua "require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())";
    };
    _internal.which-key.rust = {
      K = [(rawLua "vim.lsp.buf.hover") "Hover docs"];
      "['<leader>']" = {
        "n" = {
          "gD" = [
          ];
        };
        # rust
        #"rm" = [
        #  "<cmd>lua require'rust-tools.expand_macro'.expand_macro()<CR>"
        #  "Expand macro"
        #];
        #"rh" = [
        #  "cmd lua require('rust-tools.inlay_hints').toggle_inlay_hints()<CR>"
        #  "toggle inlay type hints"
        #];
        #"rpm" = [
        #  "cmd lua require'rust-tools.parent_module'.parent_module()<CR>"
        #  "go to parent module"
        #];
        #"rJ" = [
        #  "cmd lua require'rust-tools.join_lines'.join_lines()<CR>"
        #  "join lines rust"
        #];
        #"cu" = [ "lua require('crates').update_crate()" "update a crate" ];
        #"cua" =
        #  [ "lua require('crates').update_all_crates()" "update all crates" ];
        #"cU" = [ "lua require('crates').upgrade_crate()" "upgrade a crate" ];
        #"cUa" =
        #  [ "lua require('crates').upgrade_all_crates()" "upgrade all crates" ];
      };
    };
  }
