local h = require 'utils.helper'
local hostname = vim.fn.hostname()
local user = vim.fn.getenv("USER")

local on_attach = function(client, bufnr)
  -- show signature as you type
  -- require("lsp_signature").on_attach({
  --   bind = true,
  --   handler_opts = { border = "rounded" },
  --   hi_parameter = "Visual",
  --   hint_enable = false,
  -- }, bufnr)  -- Note: add in lsp client on-attach
  -- require("lsp-status").on_attach(client, bufnr)
end

-- lspconfig key-mappings via autocmd
local lazyLspMaps = function(ev)
  local legendary = require('legendary')
  local lspsaga = require('lspsaga')
  local buf = vim.lsp.buf
  local keys = {
    { 'gD',          buf.declaration,                                    description = '[g]o to [D]eclaration' },
    -- { 'gd', buf.definition, description = '[g]o to [d]efinition' },
    { 'gd',          ':Lspsaga goto_definition<cr>',                     description = '[g]o to [d]efinition' },
    { '<leader>lh',  buf.document_highlights,                            description = "[l]sp: get document [h]ighlights" },
    { '<leader>ls',  buf.document_symbols,                               description = "[l]sp: get document [s]ymbols" },
    { '<leader>lr',  h.lr('trouble', 'toggle', 'lsp_references'),        description = "[l]sp: get [r]eferences" },
    { 'K',           buf.hover,                                          description = "Hover Documentation" },
    -- { 'K', "<cmd>lua require('lspsaga.hover').render_hover_doc()<cr>", description = "Hover Documentation" },
    { 'gi',          buf.implementation,                                 description = "[g]o to [i]mplementation" },
    { '<C-k>',       buf.signature_help,                                 description = "signature Help" },
    { '<leader>lwa', buf.add_workspace_folder,                           description = "[lw]orkspace add folder" },
    { '<leader>lwr', buf.remove_workspace_folder,                        description = "[lw]orkspace remove folder" },
    { '<leader>lwd', h.lr('trouble', 'toggle', 'workspace_diagnostics'), description = "[l]ist [w]orkspace [d]iagnostics" },
    { '<leader>ldd', h.lr('trouble', 'toggle', 'document_diagnostics'),  description = "[l]ist [d]ocument [d]iagnostics" },
    {
      '<leader>lwl',
      function()
        print(vim.inspect(buf.list_workspace_folders()))
      end,
      description = "[wl] list workspace folder"
    },
    { '<leader>D',   buf.type_definition,               description = "[D] show type definition" },
    -- { '<leader>rn',  buf.rename, description = "[r]e[n]ame selection" },
    { '<leader>rnn', [[:Lspsaga rename<cr>]],           description = "[r]e[n]ame selection [n] local" },
    { '<leader>rnN', [[:Lspsaga rename ++project<cr>]], description = "[r]e[n]ame selection [N] across project" },
    { '<leader>lc',  buf.code_action,                   description = "perform [c]ode [a]ction", },
    -- { '<leader>gr',  buf.references, description = "[g]et [r]eferences" },
    {
      '<leader>rf',
      function()
        buf.format { async = true }
      end,
      description = "[r]un [f]ormat"
    },
  }

  legendary.keymap({
    itemgroup = 'LSP Mappings',
    icon = '📜',
    description = 'LSP related commands.',
    keymaps = vim.iter(keys):map(function(key)
      key.opts = keys.opts or {}
      key.opts.buffer = ev.buf
      return key
    end):totable()
  })
end

return h.mapNixPlugin {

  { "smjonas/inc-rename.nvim",
    cmd = "IncRename",
    config = true,
    keys = {
      { '<leader>rN<space>', ':IncRename<cr>', 'Incremntal Rename' }
    }
  },

  -- output buffer of neovim lua repl that you can send local buffer to
  { 'bfredl/nvim-luadev',
    cmd = 'Luadev',
    keys = {
      { '<leader>rl', '<cmd>Luadev<cr>',                       noremap = false, silent = false, mode = "v", desc = 'Open Luadev terminal' },
      { '<leader>rr', '<Plug>(Luadev-Run)',                    noremap = false, silent = false, mode = "v", desc = 'Execute the current line' },
      { '<leader>rr', '<Plug>(Luadev-RunLine)',                noremap = false, silent = false, mode = "n", desc = 'Operator to execute lua code over a movement or text object.' },
      { '<leader>rR', 'ggVG<bar><Plug>(Luadev-Run)<bar><c-o>', noremap = false, silent = true,  mode = "n", desc = 'Execute whole file' },
      { '<leader>rc', '<Plug>(Luadev-RunWord)',                noremap = false, silent = false, mode = "n", desc = 'Eval identifier under cursor, including `table.attr`' },
      { '<leader>rw', '<Plug>(Luadev-Complete)',               noremap = false, silent = false, mode = "n", desc = 'in insert mode: complete (nested) global table fields' },
    }
  },

  -- { 'nvim-lua/lsp-status.nvim',
  --   -- enabled = false, -- not currently configured/using
  --   nix_disable = true,
  --   dependencies = { 'neovim/nvim-lspconfig' },
  --   config = function ()
  --     local lsp_status = require('lsp-status')
  --     lsp_status.register_progress()
  --   end
  -- },


  { 'folke/neodev.nvim',
    dependencies = {
      'rcarriga/nvim-dap-ui',
    },
    opts = {
      library = {
        enabled = true,
        runtime = true,
        types = true,
        plugins = true,
        library = {
          plugins = {
            "nvim-dap-ui"
          },
          types = true
        },
      },
      setup_jsonls = true,
      lspconfig = false,
      override = function(root_dir, library)
        if root_dir:find(vim.fn.expand("~/config"), 1, true) == 1 then
          library.enabled = true
          library.plugins = true
        end
      end,
    },
  },

  -- lsp config
  -- LSP Configuration & Plugins
  { 'neovim/nvim-lspconfig',
    -- lazy = false,
    dependencies = {
      -- nvim_nu,
      -- cmp
      'hrsh7th/nvim-cmp',
      'hrsh7th/cmp-nvim-lsp',
      -- 'ray-x/lsp_signature.nvim',
      'mrjones2014/legendary.nvim',
      'bfredl/nvim-luadev', -- repl
      -- Useful status updates for LSP
      -- { 'j-hui/fidget.nvim', -- still fucking broken with legacy tag, fuck ths.
      --   tag = "legacy",
      --   enabled = false,
      --   branch = "legacy",
      --   commit = "90c22e47be057562ee9566bad313ad42d622c1d3",
      --   nix_disable = true,
      --   event = "LspAttach",
      --   opts = {},
      -- },
      { 'nvimdev/lspsaga.nvim',
        cmd = 'Lspsaga',
        config = function()
          require('lspsaga').setup({
            finder = {
              default = 'ref'
            }
          })
        end,
        dependencies = {
          'nvim-treesitter/nvim-treesitter',
          'nvim-tree/nvim-web-devicons',
        },
      },
      -- 'folke/neodev.nvim',
      -- Additional lua configuration, makes nvim stuff amazing!

    },
    keycommands_meta = {
      group_name = 'LSP',
      description = 'Language Server Protocol',
      icon = '󰼭',
      default_opts = { -- only applies to this lazy keygroup
        silent = true,
      }
    },
    keycommands = {
      { '<leader>lss', "Telescope lsp_document_symbols",          '[l]ist LSP Document [s]ymbols (Telescope)',           'TelescopeDocumentSymbols' },
      { '<leader>lws', "Telescope lsp_workspace_symbols",         '[l]ist LSP Document [s]ymbols (Telescope)',           'TelescopeWorkspaceSymbols' },
      { '<leader>lwS', "Telescope lsp_dynamic_workspace_symbols", '[l]ist Telescope LSP Document [s]ymbols (Telescope)', 'TelescopeWorkspaceDynamicSymbols' },

      { '<leader>lt',  "Telescope lsp_type_definitions",          '[l]ist [t]ype definitions (telescope)',               'TelescopeTypeDefinitions' },
      { '<leader>li',  "Telescope lsp_implementations",           '[l]ist [i]mplementations (telescope)',                'TelescopeImplementations' },
      { '<leader>lso', "Telescope lsp_outgoing_calls",            '[ls]: list [o]utgoing calls (telescope)',             'TelescopeOutgoingCalls' },
      { '<leader>lsi', "Telescope lsp_incoming_calls",            '[ls]: list [i]ncoming calls (telescope)',             'TelescopeIncomingCalls' },
      { '<leader>lsd', "Telescope lsp_definitions",               '[ls]: list [d]efinitions (telescope)',                'TelescopeDefinitions' },
      { '<leader>lsr', "Telescope lsp_references",                '[ls]: list [r]eferences (telescope)',                 'TelescopeReferences' },
    },
    config = function()
      local lspconfig = require('lspconfig')

      local legendary = require('legendary')
      legendary.autocmd({
        name = 'LspOnAttachAutocmds',
        clear = true,
        {
          'LspAttach',
          lazyLspMaps
        },
        -- { -- if you keep your curosr near a diagnostic it catches focus
        --   'CursorHold',
        --   vim.diagnostic.open_float,
        -- },
      })

      local cmp_caps = {}
      if vim.g.enable_cmp then
        cmp_caps = require('cmp_nvim_lsp').default_capabilities()
      end

      -- https://github.com/neovim/nvim-lspconfig/wiki/Autocompletion
      -- https://github.com/hrsh7th/cmp-nvim-lsp/issues/42#issuecomment-1283825572
      local capabilities = vim.tbl_deep_extend(
        'force',
        vim.lsp.protocol.make_client_capabilities(),
        cmp_caps,
        -- File watching is disabled by default for neovim.
        -- See: https://github.com/neovim/neovim/pull/22405
        { workspace = { didChangeWatchedFiles = { dynamicRegistration = true } } }
      );

      -- local capabilities = vim.lsp.protocol.make_client_capabilities()
      -- capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

      -- bash
      lspconfig.bashls.setup({
        cmd = { "bash-language-server" },
        on_attach = on_attach,
        capabilities = capabilities,
      })

      -- -- golang
      lspconfig.gopls.setup({
        cmd = { "gopls" },
        on_attach = on_attach,
        capabilities = capabilities,
      })

      -- lua
      lspconfig.lua_ls.setup({
        cmd = { "lua-language-server" },
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              checkThirdParty = false,
              library = {
                vim.fn.expand "$VIMRUNTIME",
                '~/.config/nvim/nix-plugins',
                '~/.config/nvim/lazy-plugins',
                --get_lvim_base_dir(),
                require("neodev.config").types(),
                "${3rd}/busted/library",
                "${3rd}/luassert/library",
              },
              maxPreload = 5000,
              preloadFileSize = 10000,
            },
            telemetry = { enable = false },
          }
        }
      })

      -- nix lsp
      local config_flake = '(builtins.getFlake ("git+file:///home/'..user..'/config"))'
      lspconfig.nixd.setup({
        -- autostart = false,
        autostart = true,
        -- cmd = { "nixd", "--log=verbose"},
        cmd = { "nixd", "--inlay-hints=true", "--semantic-tokens=true" },
        -- cmd = { "nixd" },
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          nixd = {
            nixpkgs = {
              -- expr = "import <nixpkgs> { }",
              expr = 'import (builtins.getFlake "/home/' .. user .. '/config").inputs.nixpkgs { }',
            },
            formatting = {
              command = { "nix fmt" },
            },
            options = {
              nixos = {
                expr = '(let currFlake = builtins.getFlake ("git+file://" + toString ./.); in if builtins.hasAttr "nixd" currFlake then currFlake.nixd.options.nixos else '..config_flake..'.nixosConfigurations.' .. hostname .. '.options)',
                -- expr = config_flake..'.nixosConfigurations.'..hostname..'.options',
              },
              -- nixos_currflake = {
              --   expr = '(builtins.getFlake ("git+file://" + toString ./.)).nixd.options.nixos'
              -- },
              home_manager = {
                expr = '(let currFlake = builtins.getFlake ("git+file://" + toString ./.); in if (builtins.hasAttr "nixd" currFlake) && (builtins.hasAttr "home-manager" currFlake.nixd.options) then currFlake.nixd.options.home-manager else '..config_flake..'.homeConfigurations.' .. user .. '.options)',
                -- expr = config_flake..'.homeConfigurations.'..user..'.options',
              },
              -- -- home_manager_currflake = {
              -- --   expr = '(builtins.getFlake ("git+file://" + toString ./.)).nixd.options.home-manager'
              -- -- },
              flake_parts = {
                expr = '(builtins.getFlake ("git+file://" + toString ./.)).debug.options',
              },
              perSystem = {
                expr = '(builtins.getFlake ("git+file://" + toString ./.)).currentSystem.options',
              },
            },
          },
        },
      })
      -- lspconfig.nil_ls.setup({
      --   autostart = false,
      --   -- autostart = true,
      --   cmd = { "nil" },
      --   on_attach = on_attach,
      --   capabilities = capabilities,
      --   settings = {
      --     ['nil'] = {
      --       formatting = {
      --         command = { "alejandro" }
      --       }
      --     }
      --   }
      -- })

      lspconfig.nushell.setup({
        cmd = { "nu", "--lsp" }
      })

      -- python lsp
      lspconfig.pyright.setup({
        cmd = { "pyright" },
        on_attach = on_attach,
        capabilities = capabilities,
      })

      -- rust lsp
      lspconfig.rust_analyzer.setup({
        cmd = { "rust-analyzer" },
        on_attach = on_attach,
        capabilities = capabilities,
      })

      -- dockerfile lsp
      lspconfig.dockerls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
      })

      -- dockerfile lsp
      lspconfig.docker_compose_language_service.setup({
        on_attach = on_attach,
        capabilities = capabilities,
      })

      -- yaml lsp
      lspconfig.yamlls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          redhat = {
            telemetry = {
              enabled = false,
            },
          },
        },
      })

      -- zk (zettelkasten note taking) lsp
      lspconfig.zk.setup({
        on_attach = on_attach,
        capabilities = capabilities,
      })
    end,
  },

}



-- WIP lspconfig
-- lspconfig.setup({
--     inlay_hints = { enabled = true },
--     capabilities = {
--       workspace = {
--         didChangeWatchedFiles = {
--           dynamicRegistration = false,
--         },
--       },
--     },
--     servers = {
--       -- ansiblels = {},
--       bashls = {},
--       cssls = {},
--       dockerls = {},
--       ruff_lsp = {},
--       -- tailwindcss = {
--       --   root_dir = function(...)
--       --     return require("lspconfig.util").root_pattern(".git")(...)
--       --   end,
--       -- },
--       -- tsserver = {
--       --   -- root_dir = function(...)
--       --   --   return require("lspconfig.util").root_pattern(".git")(...)
--       --   -- end,
--       --   single_file_support = false,
--       --   settings = {
--       --     typescript = {
--       --       inlayHints = {
--       --         includeInlayParameterNameHints = "literal",
--       --         includeInlayParameterNameHintsWhenArgumentMatchesName = false,
--       --         includeInlayFunctionParameterTypeHints = true,
--       --         includeInlayVariableTypeHints = false,
--       --         includeInlayPropertyDeclarationTypeHints = true,
--       --         includeInlayFunctionLikeReturnTypeHints = true,
--       --         includeInlayEnumMemberValueHints = true,
--       --       },
--       --     },
--       --     javascript = {
--       --       inlayHints = {
--       --         includeInlayParameterNameHints = "all",
--       --         includeInlayParameterNameHintsWhenArgumentMatchesName = false,
--       --         includeInlayFunctionParameterTypeHints = true,
--       --         includeInlayVariableTypeHints = true,
--       --         includeInlayPropertyDeclarationTypeHints = true,
--       --         includeInlayFunctionLikeReturnTypeHints = true,
--       --         includeInlayEnumMemberValueHints = true,
--       --       },
--       --     },
--       --   },
--       -- },
--       html = {},
--       gopls = {},
--       marksman = {},
--       -- pyright = {
--       --   enabled = false,
--       -- },
--       rust_analyzer = {
--         settings = {
--           ["rust-analyzer"] = {
--             procMacro = { enable = true },
--             cargo = { allFeatures = true },
--             checkOnSave = {
--               command = "clippy",
--               extraArgs = { "--no-deps" },
--             },
--           },
--         },
--       },
--       yamlls = {
--         settings = {
--           yaml = {
--             keyOrdering = false,
--           },
--         },
--       },
--       lua_ls = {
--         -- enabled = false,
--         -- cmd = { "/home/folke/projects/lua-language-server/bin/lua-language-server" },
--         single_file_support = true,
--         settings = {
--           Lua = {
--             -- not necessary with neodev
--             -- workspace = {
--             --   checkThirdParty = false,
--             --   library = {
--             --     vim.fn.expand "$VIMRUNTIME",
--             --     '/home/'..user..'/.config/nvim/lua',
--             --     --get_lvim_base_dir(),
--             --     require("neodev.config").types(),
--             --     "${3rd}/busted/library",
--             --     "${3rd}/luassert/library",
--             --   },
--             --   maxPreload = 5000,
--             --   preloadFileSize = 10000,
--             -- },
--             telemetry = { enable = false },
--             completion = {
--               workspaceWord = true,
--               callSnippet = "Both",
--             },
--             misc = {
--               parameters = {
--                 -- "--log-level=trace",
--               },
--             },
--             hover = { expandAlias = false },
--             hint = {
--               enable = true,
--               setType = false,
--               paramType = true,
--               paramName = "Disable",
--               semicolon = "Disable",
--               arrayIndex = "Disable",
--             },
--             doc = {
--               privateName = { "^_" },
--             },
--             type = {
--               castNumberToInteger = true,
--             },
--             diagnostics = {
--               globals = { "vim" },
--               disable = { "incomplete-signature-doc", "trailing-space" },
--               -- enable = false,
--               groupSeverity = {
--                 strong = "Warning",
--                 strict = "Warning",
--               },
--               groupFileStatus = {
--                 ["ambiguity"] = "Opened",
--                 ["await"] = "Opened",
--                 ["codestyle"] = "None",
--                 ["duplicate"] = "Opened",
--                 ["global"] = "Opened",
--                 ["luadoc"] = "Opened",
--                 ["redefined"] = "Opened",
--                 ["strict"] = "Opened",
--                 ["strong"] = "Opened",
--                 ["type-check"] = "Opened",
--                 ["unbalanced"] = "Opened",
--                 ["unused"] = "Opened",
--               },
--               unusedLocalExclude = { "_*" },
--             },
--             format = {
--               enable = true,
--               defaultConfig = {
--                 indent_style = "space",
--                 indent_size = "2",
--                 continuation_indent_size = "2",
--               },
--             },
--           },
--         },
--       },
--       vimls = {},
--   },
--
--
--
-- })
