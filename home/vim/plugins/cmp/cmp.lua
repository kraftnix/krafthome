--require'compe'.setup {
--  enabled = true;
--  autocomplete = true;
--  debug = false;
--  min_length = 1;
--  preselect = 'enable';
--  throttle_time = 80;
--  source_timeout = 200;
--  resolve_timeout = 800;
--  incomplete_delay = 400;
--  max_abbr_width = 100;
--  max_kind_width = 100;
--  max_menu_width = 100;
--  documentation = {
--    border = { "", "" ,"", " ", "", "", "", " " }, -- the border option is the same as `|help nvim_open_win|`
--    winhighlight = "NormalFloat:CompeDocumentation,FloatBorder:CompeDocumentationBorder",
--    max_width = 120,
--    min_width = 60,
--    max_height = math.floor(vim.o.lines * 0.3),
--    min_height = 1,
--  };
--
--  source = {
--    path = true;
--    buffer = true;
--    calc = true;
--    nvim_lsp = true;
--    nvim_lua = true;
--    vsnip = true;
--    ultisnips = true;
--    luasnip = true;
--  };
--}

local cmp = require'cmp'
cmp.setup({
    snippet = {
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
        end,
    },
    mapping = {
        ['<C-j>'] = cmp.mapping.select_next_item(),
        ['<C-k>'] = cmp.mapping.select_prev_item(),
        ['<C-Space>'] = cmp.mapping.complete(),
        --['<C-e>'] = cmp.mapping.close(),
        ['<C-u>'] = cmp.mapping.scroll_docs(-4),
        ['<C-d>'] = cmp.mapping.scroll_docs(4),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<C-s>'] = cmp.mapping.confirm({ select = true }),
        ['<CR>'] = cmp.mapping.confirm({ select = false }),
    },
    sources = {
        { name = 'path' },
        { name = 'nvim_lsp' },
        { name = 'nixpkgs' },
        { name = 'nixos' },
        { name = 'vsnip' },
        --{ name = 'orgmode' },
        { name = 'buffer',  options = {
            get_bufnrs = function()
                return vim.api.nvim_list_bufs()
            end
        }},
    },
    formatting = {
        format = function(entry, vim_item)
            --vim_item.kind = require("lspkind").presets.default[vim_item.kind] .. " " .. vim_item.kind
            -- workaround for nix/nixpkgs
            if not (vim_item.kind == "Attr") then
              vim_item.kind = require("lspkind").presets.default[vim_item.kind] .. " " .. vim_item.kind
            end
            vim_item.menu = ({
                path = "[Path]",
                buffer = "[Buffer]",
                nvim_lsp = "[LSP]",
                luasnip = "[LuaSnip]",
                vsnip = "[VSnip]",
                nvim_lua = "[Lua]",
                latex_symbols = "[Latex]",
                --orgmode = "[Org]",
            })[entry.source.name]
            return vim_item
        end,
    },
})

cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline({
    ["<C-j>"] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 'c' }),
    ["<C-k>"] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 'c' }),
  }),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})
