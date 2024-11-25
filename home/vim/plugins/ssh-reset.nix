{
  pkgs,
  dsl,
  ...
}:
with dsl; let
  cmd = command: desc: ["<cmd>${command}<cr>" desc];
in {
  plugins = with pkgs.vimPlugins; [
  ];
  # add in terminal mapping to close Term
  _internal.which-key.resetSsh = {
    "['<leader>']".a.r = cmd "lua ResetSsh()" "Reset SSH_AUTH_SOCK";
    "['<leader>']".a.k = cmd "lua SetLatestSsh()" "Set SSH_AUTH_SOCK to newest created";
  };
  lua = ''
    function ResetSsh()
      local url = vim.fn.system("get-default-ssh")
      vim.fn.setenv("SSH_AUTH_SOCK", url)
    end

    function SetLatestSsh()
      local url = vim.fn.system("get-recent-ssh")
      vim.fn.setenv("SSH_AUTH_SOCK", url)
    end
  '';
}
