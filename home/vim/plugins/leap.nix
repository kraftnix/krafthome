{
  pkgs,
  dsl,
  ...
}:
with dsl;
let
  cmd = command: desc: [
    "<cmd>${command}<cr>"
    desc
  ];
in
{
  plugins = with pkgs.vimPlugins; [
    leap-nvim
  ];
  # add in terminal mapping to close Term
  _internal.which-key.leap = {
    #"['<leader>']".k.r = cmd "lua ResetSsh()" "Toggle NeoZoom";
  };
  lua = ''
    require('leap').add_default_mappings()
  '';
}
