{
  inputs,
  self,
  ...
}:
{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
{
  /*
     NOTE: wip fzf
    open ~/.zsh_history | split row ': ' | str trim | parse -r '(?P<timestamp>\d+):0;(?P<cmd>.*)' | get cmd | str collect "\n" | fzf
  */
  imports = [ self.homeModules.nushell-unstable ];
  programs.nushell-unstable = {
    enable = true;
    enableStarship = true;
    settings = {
      filesize_metric = false;
      table_mode = "rounded";
      use_ls_colors = true;
      rm_always_trash = false;
      footer_mode = 25;
      quick_completions = true;
      partial_completions = true;
      animate_prompt = false;
      float_precision = 2;
      use_ansi_coloring = true;
      filesize_format = "auto";
      edit_mode = "emacs";
      max_history_size = 100000;
      menus = [
        {
          name = "help_menu";
          only_buffer_difference = true;
          marker = "| ";
          type = {
            layout = "description";
            columns = 4;
            col_width = 20;
            col_padding = 2;
            selection_rows = 4;
            description_rows = 10;
          };
          style = {
            text = "purple";
            selected_text = "orange";
            description_text = "green";
          };
        }
        {
          name = "history_menu";
          only_buffer_difference = true;
          marker = "? ";
          type = {
            layout = "columnar";
            columns = 4;
            col_width = 20;
            col_padding = 2;
          };
          style = {
            text = "purple";
            selected_text = "orange";
            description_text = "green";
          };
        }
      ];
    };
  };
}
