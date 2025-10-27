let kb = [
  { # [Alt + c]: Change dir
    name: change_dir_with_fzf
    modifier: alt
    keycode: char_c
    mode: emacs
    event: {
      send: executehostcommand,
      cmd: "cd (ls | where type == dir | each { |it| ls $it.name } | flatten | get name | str join (char nl) | fzf | decode utf-8 | str trim)"
    }
  }
  { # [Alt + r]: Change dir to repos
    name: change_dir_to_repo_with_fzf
    modifier: alt
    keycode: char_r
    mode: emacs
    event: {
      send: executehostcommand,
      cmd: "cd (ls ~/repos | where type == dir | each { |it| ls $it.name } | flatten | get name | str join (char nl) | fzf | decode utf-8 | str trim)"
    }
  }
  { # [Ctrl + t]: Change dir to repos
    name: fzf_select_file
    modifier: control
    keycode: char_t
    mode: [emacs, vi_normal, vi_insert]
    event: {
      send: executehostcommand
      cmd: "commandline edit --insert (fd -H | str join (char nl) | fzf | decode utf-8 | str trim)"
    }
  }

  # Completion Menu Movements
  { # [Tab]: Completion Menu
    name: completion_menu
    modifier: none
    keycode: tab
    mode: [emacs vi_normal vi_insert]
    event: {
      until: [
        { send: Menu name: completion_menu }
        { send: MenuNext }
      ]
    }
  }
  { # [Ctrl + j]: Completion Menu
    name: completion_menu_j
    modifier: control
    keycode: char_j
    mode: [emacs vi_normal vi_insert]
    event: {
      until: [
        { send: Menu name: completion_menu }
        { send: MenuNext }
      ]
    }
  }

  { # [Shift + Backtab]: Completion Menu (previous)
    name: completion_previous
    modifier: shift
    keycode: backtab
    mode: [emacs, vi_normal, vi_insert] # Note: You can add the same keybinding to all modes by using a list
    event: { send: MenuPrevious }
  }
  { # [Ctrl + k]: Completion Menu (previous)
    name: completion_previous_k
    modifier: control
    keycode: char_k
    mode: [emacs, vi_normal, vi_insert] # Note: You can add the same keybinding to all modes by using a list
    event: { send: MenuPrevious }
  }

  ## Shell Control
  { # [Control + h]: Move work left
    name: move_word_left
    modifier: control
    keycode: char_h
    mode: [emacs, vi_normal, vi_insert]
    event: {
      until: [
        { edit: MoveWordLeft }
      ]
    }
  }
  # TODO: not working
  { # [Control + Alt + h]: Move to beginning of line
    name: move_to_beginning
    modifier: control_alt
    keycode: char_h
    mode: [emacs, vi_normal, vi_insert]
    event: {
      until: [
        { edit: MoveToLineStart }
      ]
    }
  }
  { # [Control + l]: Move work right
    name: move_work_left
    modifier: control
    keycode: char_l
    mode: [emacs, vi_normal, vi_insert]
    event: {
      until: [
        { edit: MoveWordRight }
      ]
    }
  }
  # TODO: not working
  { # [Control + alt + l]: Move to end of line
    name: move_to_end
    modifier: control_alt
    keycode: char_l
    mode: [emacs, vi_normal, vi_insert]
    event: {
      until: [
        { edit: MoveToLineEnd }
      ]
    }
  }

  { # [Control + y]: yank / copy
    name: yank
    modifier: control
    keycode: char_y
    mode: emacs
    event: {
      until: [
        { edit: PasteCutBufferAfter }
      ]
    }
  }

  { # [Control + u]: Delete cursor -> start
    name: unix-line-discard
    modifier: control
    keycode: char_u
    mode: [emacs, vi_normal, vi_insert]
    event: {
      until: [
        { edit: CutFromLineStart }
      ]
    }
  }

  # { # [Control + k]: Delete cursor -> end
  #   name: kill-line
  #   modifier: control
  #   keycode: char_k
  #   mode: [emacs, vi_normal, vi_insert]
  #   event: {
  #     until: [
  #       { edit: CutToLineEnd }
  #     ]
  #   }
  # }

  { # [Control + e]: Open EDITOR
    name: open_editor
    modifier: control
    keycode: char_e
    mode: [emacs, vi_normal, vi_insert]
    event: { send: OpenEditor }
  }

  ## Menus
  { # [Control + r]: History Menu
    name: history_menu
    modifier: control
    keycode: char_r
    mode: emacs
    event: { send: Menu name: history_menu }
  }

  ## Keybindings used to trigger the user defined menus
  { # [Control + t]: Trigger Commands Menu
    name: commands_menu
    modifier: control
    keycode: "char_;"
    mode: [emacs, vi_normal, vi_insert]
    event: { send: Menu name: commands_menu }
  }

  { # [Alt + o]: Trigger Vars Menu
    name: vars_menu
    modifier: alt
    keycode: char_o
    mode: [emacs, vi_normal, vi_insert]
    event: { send: Menu name: vars_menu }
  }

  { # [Alt + s]: Trigger Commands (with descriptions) Menu
    name: commands_with_description
    modifier: alt
    keycode: char_s
    mode: [emacs, vi_normal, vi_insert]
    event: { send: Menu name: commands_with_description }
  }

  { # [Control + /]: Trigger Commands (with descriptions) Menu
    name: help_menu
    modifier: control
    keycode: "char_/"
    mode: [emacs, vi_normal, vi_insert]
    event: { send: Menu name: commands_with_description }
  }
]

$env.config = (
  $env.config | upsert keybindings (
    $env.config.keybindings ++ $kb
  )
)
