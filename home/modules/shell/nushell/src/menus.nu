let me = [

  { # Completion Menu
    name: completion_menu
    only_buffer_difference: false
    marker: "| "
    type: {
        layout: columnar
        columns: 4
        col_width: 20   # Optional value. If missing all the screen width is used to calculate column width
        col_padding: 2
    }
    style: {
        text: green
        selected_text: green_reverse
        description_text: yellow
    }
    # # buffer is the full current buffer of the command
    # source: { |buffer, position|
    #   # echo $buffer | describe | default "" | str trim | append "\n" | save --append /home/kraftnix/nu_log.txt
    #   echo $buffer | save --append /home/kraftnix/nu_log.txt
    #   # echo $position | save --append /home/kraftnix/nu_log.txt
    #   ^lnav -
    # }
  }

  { # History Menu
    name: history_menu
    only_buffer_difference: true
    marker: "? "
    type: {
        layout: list
        page_size: 10
    }
    style: {
        text: green
        selected_text: green_reverse
        description_text: yellow
    }
  }

  { # Help Menu
    name: help_menu
    only_buffer_difference: true
    marker: "? "
    type: {
        layout: description
        columns: 4
        col_width: 20   # Optional value. If missing all the screen width is used to calculate column width
        col_padding: 2
        selection_rows: 4
        description_rows: 10
    }
    style: {
        text: green
        selected_text: green_reverse
        description_text: yellow
    }
  }

  { # Nu Commands menu
    name: commands_menu
    only_buffer_difference: false
    marker: "# "
    type: {
        layout: columnar
        columns: 4
        col_width: 20
        col_padding: 2
    }
    style: {
        text: green
        selected_text: green_reverse
        description_text: yellow
    }
    source: { |buffer, position|
        $nu.scope.commands
        | where name =~ $buffer
        | each { |it| {value: $it.name description: $it.usage} }
    }
  }

  { # Vars in scope Menu
    name: vars_menu
    only_buffer_difference: true
    marker: "# "
    type: {
        layout: list
        page_size: 10
    }
    style: {
        text: green
        selected_text: green_reverse
        description_text: yellow
    }
    source: { |buffer, position|
        $nu.scope.vars
        | where name =~ $buffer
        | sort-by name
        | each { |it| {value: $it.name description: $it.type} }
    }
  }

  { # Commands with descriptions Menu
    name: commands_with_description
    only_buffer_difference: true
    marker: "# "
    type: {
        layout: description
        columns: 4
        col_width: 20
        col_padding: 2
        selection_rows: 4
        description_rows: 10
    }
    style: {
        text: green
        selected_text: green_reverse
        description_text: yellow
    }
    source: { |buffer, position|
        $nu.scope.commands
        | where name =~ $buffer
        | each { |it| {value: $it.name description: $it.usage} }
    }
  }
]

$env.config = (
  $env.config | upsert menus (
    $env.config.menus ++ $me
  )
)
