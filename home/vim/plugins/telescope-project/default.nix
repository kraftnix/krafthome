{
  pkgs,
  dsl,
  ...
}:
with dsl; {
  plugins = with pkgs.vimPlugins; [
    telescope-project-nvim
  ];
  lua = ''
    require('telescope').setup {
      extensions = {
        project = {
          base_dirs = {
            '~/',
            '~/repos',
          },
          -- theme = "dropdown"
        }
      }
    }
    require'telescope'.load_extension('project')
  '';
}
