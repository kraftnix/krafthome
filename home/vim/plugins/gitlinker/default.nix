# Adapater for alternative git forges
# Similar to :GBrowse from fugitive but supports more forges
{
  pkgs,
  dsl,
  lib,
  ...
}:
with dsl;
with lib; {
  plugins = with pkgs.vimPlugins; [gitlinker-nvim];
  # lua = builtins.readFile ./gitlinker.lua;
  _internal.which-key.gitlinker."['<leader>']".g = {
    y = [
      "<cmd>lua require'gitlinker'.get_buf_range_url('n', {action_callback = require'gitlinker.actions'.open_in_browser})<cr>" #, {silent = true})
    ];
    Y = ["<Cmd>lua require'gitlinker'.get_buf_range_url('n')<CR> "];
  };
  #lua = builtins.readFile ./gitlinker.lua + ''
  #  vim.api.nvim_set_keymap('n', '<leader>gy', '<cmd>lua require"gitlinker".get_buf_range_url("n", {action_callback = require"gitlinker.actions".open_in_browser})<cr>', {silent = true})
  #  vim.api.nvim_set_keymap('v', '<leader>gy', '<cmd>lua require"gitlinker".get_buf_range_url("v", {action_callback = require"gitlinker.actions".open_in_browser})<cr>', {})
  #'';

  lua = mkAfter ''
    ${(builtins.readFile ./gitlinker.lua)}
    map('n', '<leader>gyy', '<cmd>lua require"gitlinker".get_buf_range_url()<cr>', {silent = true, noremap = true})
    map('v', '<leader>gyy', '<cmd>lua require"gitlinker".get_buf_range_url()<cr>', {silent = true, noremap = true})
    map('n', '<leader>gyb', '<cmd>lua require"gitlinker".get_buf_range_url("n", {action_callback = require"gitlinker.actions".open_in_browser})<cr>', {silent = true, noremap = true})
    map('v', '<leader>gyb', '<cmd>lua require"gitlinker".get_buf_range_url("v", {action_callback = require"gitlinker.actions".open_in_browser})<cr>', {silent = true})
    map('n', '<leader>gyB', '<cmd>lua require"gitlinker".get_repo_url({action_callback = require"gitlinker.actions".open_in_browser})<cr>', {silent = true})
    map('n', '<leader>gyr', '<cmd>lua require"gitlinker".get_repo_url()<cr>', {silent = true})
  '';

  # vnoremap = {
  #   "<leader>gyy" = "lua require\"gitlinker\".get_buf_range_url()<cr>"; # {silent = true, noremap = true})
  #   "<leader>gyb" = "lua require\"gitlinker\".get_buf_range_url(\"v\", {action_callback = require\"gitlinker.actions\".open_in_browser})<cr>"; # {silent = true})
  # };
  # nnoremap = {
  #   "<leader>gyy" = "lua require\"gitlinker\".get_buf_range_url()<cr>"; # {silent = true, noremap = true})
  #   "<leader>gyb" = "lua require\"gitlinker\".get_buf_range_url(\"n\", {action_callback = require\"gitlinker.actions\".open_in_browser})<cr>"; # {silent = true, noremap = true})
  #   "<leader>gyB" = "lua require\"gitlinker\".get_repo_url({action_callback = require\"gitlinker.actions\".open_in_browser})<cr>"; # {silent = true})
  #   "<leader>gyr" = "lua require\"gitlinker\".get_repo_url()<cr>"; # {silent = true}
  # };
}
