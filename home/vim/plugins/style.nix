# Themes + Status Line (lualine atm)
{
  pkgs,
  dsl,
  ...
}:
with dsl; {
  plugins = with pkgs.vimPlugins; [
    dracula-vim
    tokyonight-nvim
    nightfox-nvim
    lualine-nvim
    tabline-nvim
    nvim-web-devicons
    transparent-nvim
    colorizer
  ];

  lua = ''
    vim.cmd 'set termguicolors'
    vim.cmd 'colorscheme base16-ffffff'

    -- add transparency
    -- vim.cmd 'hi Normal ctermbg=NONE guibg=NONE'
    -- vim.cmd 'hi NonText ctermbg=NONE guibg=NONE'
    -- vim.cmd 'hi SignColumn ctermbg=NONE guibg=NONE'

    ${builtins.readFile ./tabline.lua}
    vim.cmd[[
      set guioptions-=e " Use showtabline in gui vim
      set sessionoptions+=tabpages,globals " store tabpages and globals in session
    ]]
  '';
  setup.tabline.show_index = false;

  /*
     NOTE: moved to tabline.lua
  setup.lualine = {
    options = {
      theme = "palenight";
      component_separators = {
        left = "";
        right = "";
      };
      section_separators = {
        left = "";
        right = "";
      };
      globalstatus = true;
    };
    sections = {
      lualine_a = [ "mode" ];
      lualine_b = [ "branch" "diff" "diagnostics" ];
      lualine_c = [ "filename" ];
      lualine_x = [ "encoding" "fileformat" ];
      lualine_y = [ "progress" ];
      lualine_z = [ "location" ];
    };
    tabline = { };
    #extensions = [ "nvim-tree" "toggleterm" "quickfix" "symbols-outline" ];
  };
  */
}
