local h = require 'utils.helper'

-- for NullLS
-- format(async)
local async_formatting = function(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  vim.lsp.buf_request(
    bufnr,
    "textDocument/formatting",
    vim.lsp.util.make_formatting_params({}),
    function(err, res, ctx)
      if err then
        local err_msg = type(err) == "string" and err or err.message
        -- you can modify the log message / level (or ignore it completely)
        vim.notify("formatting: " .. err_msg, vim.log.levels.WARN)
        return
      end

      -- don't apply results if buffer is unloaded or has been modified
      if not vim.api.nvim_buf_is_loaded(bufnr) or vim.api.nvim_buf_get_option(bufnr, "modified") then
        return
      end

      if res then
        local client = vim.lsp.get_client_by_id(ctx.client_id)
        vim.lsp.util.apply_text_edits(res, bufnr, client and client.offset_encoding or "utf-16")
        vim.api.nvim_buf_call(bufnr, function()
          vim.cmd("silent noautocmd update")
        end)
      end
    end
  )
end
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
local lsp_formatting = function(bufnr)
  vim.lsp.buf.format({
    filter = function(client)
      -- apply whatever logic you want (in this example, we'll only use null-ls)
      return client.name == "none-ls"
    end,
    bufnr = bufnr,
  })
end

return h.mapNixPlugin {

  -- nushell LSP
  { 'LhKipp/nvim-nu',
    opts = {
      use_lsp_features = true, -- requires https://github.com/jose-elias-alvarez/null-ls.nvim
      -- lsp_feature: all_cmd_names is the source for the cmd name completion.
      -- It can be
      --  * a string, which is interpreted as a shell command and the returned list is the source for completions (requires plenary.nvim)
      --  * a list, which is the direct source for completions (e.G. all_cmd_names = {"echo", "to csv", ...})
      --  * a function, returning a list of strings and the return value is used as the source for completions
      all_cmd_names = [[nu -c 'help commands | get name | str join "\n"']]
    },
    dependencies = { 'nvim-tools/none-ls.nvim' }
  },

  -- NullLS
  { 'nvim-tools/none-ls.nvim',
    nix_name = 'none-ls.nvim',
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        sources = {
          -- null_ls.builtins.formatting.stylua,
          -- null_ls.builtins.diagnostics.eslint,
          null_ls.builtins.completion.spell,
          -- null_ls.builtins.formatting.nixpkgs_fmt, # does auto-formatting on save
        },
        debug = true,
        on_attach = function(client, bufnr)
          if client.supports_method("textDocument/formatting") then
            vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
            vim.api.nvim_create_autocmd("BufWritePost", {
              group = augroup,
              buffer = bufnr,
              callback = function()
                async_formatting(bufnr)
                lsp_formatting(bufnr)
              end,
            })
          end
        end,
      })
    end
  }

}
