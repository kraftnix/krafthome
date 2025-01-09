# returns true if provided env var exists and true-like
#   i.e. "true", 1, "y"
def testBoolikeVar [ envName : string ]: any -> bool {
  if ($env | get -i $envName) == null {
    false
  } else {
    let v = ($env | get $envName)
    ($v == "true" or $v == 1 or $v == "y" or $v == "1" or $v == true)
  }
}

let enableAtuin = (testBoolikeVar NUSHELL_ENABLE_ATUIN)
let enableStarship = (testBoolikeVar NUSHELL_ENABLE_STARSHIP)

source ~/.config/nushell/theme.nu

# The default config record. This is where much of your global configuration is setup.
$env.config = ($env.config
  | upsert history {
    max_size: 100000 # Session has to be reloaded for this to take effect
    sync_on_enter: true # Enable to share history between multiple sessions, else you have to close the session to write history to file
    file_format: "plaintext" # "sqlite" or "plaintext"
    # TODO: currently says unknown
    # history_isolation: false # true enables history isolation, false disables it. true will allow the history to be isolated to the current session. false will allow the history to be shared across all sessions.
  }
  | upsert completions {
    case_sensitive: false # set to true to enable case-sensitive completions
    quick: true  # set this to false to prevent auto-selecting completions when only one remains
    partial: true  # set this to false to prevent partial filling of the prompt
    algorithm: "fuzzy"  # prefix or fuzzy
    external: {
      # see ./carapace.nu
      max_results: 500 # setting it lower can improve completion performance at the cost of omitting some options
    }
  }
  | upsert float_precision 2 # the precision for displaying floats in tables
  | upsert edit_mode emacs # emacs, vi
  | upsert shell_integration {
    # osc2 abbreviates the path if in the home_dir, sets the tab/window title, shows the running command in the tab/window title
    osc2: true
    # osc7 is a way to communicate the path to the terminal, this is helpful for spawning new tabs in the same directory
    osc7: true
    # osc8 is also implemented as the deprecated setting ls.show_clickable_links, it shows clickable links in ls output if your terminal supports it. show_clickable_links is deprecated in favor of osc8
    osc8: true
    # osc9_9 is from ConEmu and is starting to get wider support. It's similar to osc7 in that it communicates the path to the terminal
    osc9_9: false
    # osc133 is several escapes invented by Final Term which include the supported ones below.
    # 133;A - Mark prompt start
    # 133;B - Mark prompt end
    # 133;C - Mark pre-execution
    # 133;D;exit - Mark execution finished with exit code
    # This is used to enable terminals to know where the prompt is, the command is, where the command finishes, and where the output of the command is
    osc133: true
    # osc633 is closely related to osc133 but only exists in visual studio code (vscode) and supports their shell integration features
    # 633;A - Mark prompt start
    # 633;B - Mark prompt end
    # 633;C - Mark pre-execution
    # 633;D;exit - Mark execution finished with exit code
    # 633;E - NOT IMPLEMENTED - Explicitly set the command line with an optional nonce
    # 633;P;Cwd=<path> - Mark the current working directory and communicate it to the terminal
    # and also helps with the run recent menu in vscode
    osc633: true
    # reset_application_mode is escape \x1b[?1l and was added to help ssh work better
    reset_application_mode: true
  } # enables terminal markers and a workaround to arrow keys stop working issue
  | upsert keybindings []
  | upsert menus []
  # | upsert plugins_gc {
  #   default: {
  #     enabled: true # true to enable stopping of inactive plugins
  #     stop_after: 10sec # how long to wait after a plugin is inactive to stop it
  #   }
  # }
)

source ~/.config/nushell/keybindings.nu
source ~/.config/nushell/menus.nu
source ~/.config/nushell/carapace.nu

let carapace_completer = {|spans: list<string>|
  carapace $spans.0 nushell ...$spans
  | from json
  | if ($in | default [] | where value == $"($spans | last)ERR" | is-empty) { $in } else { null }
}
let fish_completer = {|spans|
  fish --command $'complete "--do-complete=($spans | str join " ")"'
  | $"value(char tab)description(char newline)" + $in
  | from tsv --flexible --no-infer
}
let zoxide_completer = {|spans|
  $spans | skip 1 | zoxide query -l ...$in | lines | where {|x| $x != $env.PWD}
}
# This completer will use carapace by default
let external_completer = {|spans|
  let expanded_alias = scope aliases
  | where name == $spans.0
  | get -i 0.expansion

  let spans = if $expanded_alias != null {
    $spans
    | skip 1
    | prepend ($expanded_alias | split row ' ' | take 1)
  } else {
    $spans
  }

  match $spans.0 {
    # carapace completions are incorrect for nu
    nu => $fish_completer
    # fish completes commits and branch names in a nicer way
    git => $fish_completer
    # carapace doesn't have completions for asdf
    asdf => $fish_completer
    # use zoxide completions for zoxide commands
    __zoxide_z | __zoxide_zi => $zoxide_completer
    _ => $carapace_completer
  } | do $in $spans
}

$env.config.completions.external = {
  enable: true
  completer: $external_completer
}

if $enableAtuin {
  source ~/.config/nushell/atuin.nu
}
if $enableStarship {
  source ~/.config/nushell/starship.nu
} else {
  def create_left_prompt_original [] {
    let dir = match (do --ignore-shell-errors { $env.PWD | path relative-to $nu.home-path }) {
      null => $env.PWD
      '' => '~'
      $relative_pwd => ([~ $relative_pwd] | path join)
    }

    let path_color = (if (is-admin) { ansi red_bold } else { ansi green_bold })
    let separator_color = (if (is-admin) { ansi light_red_bold } else { ansi light_green_bold })
    let path_segment = $"($path_color)($dir)(ansi reset)"
    let host_color = ansi blue
    let host = (open /etc/hostname | default ($env | get -i HOSTNAME | default "unknown_host"))
    let host_segment = $"$($host_color)($host)(ansi reset)"

    $path_segment | str replace --all (char path_sep) $"($host_segment)($separator_color)(char path_sep)($path_color)"
  }

  def create_right_prompt [] {
    # create a right prompt in magenta with green separators and am/pm underlined
    let time_segment = (
      [
        (ansi reset)
        (ansi magenta)
        (date now | format date '%x %X') # try to respect user's locale
      ]
      | str join
      | str replace --regex --all "([/:])" $"(ansi green)${1}(ansi magenta)"
      | str replace --regex --all "([AP]M)" $"(ansi magenta_underline)${1}"
    )

    let last_exit_code = if ($env.LAST_EXIT_CODE != 0) {
      ([
        (ansi rb)
        ($env.LAST_EXIT_CODE)
      ] | str join)
    } else { "" }

    ([$last_exit_code, (char space), $time_segment] | str join)
  }

  $env.PROMPT_COMMAND = (
    if $enableStarship {
      { || create_left_prompt }
    } else {
      { || create_left_prompt_original }
    }
  )
  $env.PROMPT_COMMAND_RIGHT = { || create_right_prompt }
  $env.PROMPT_INDICATOR = (if $enableStarship { "" } else { ">" })
  $env.PROMPT_INDICATOR_VI_INSERT = ": "
  $env.PROMPT_INDICATOR_VI_NORMAL = "〉"
  $env.PROMPT_MULTILINE_INDICATOR = "::: "
}
