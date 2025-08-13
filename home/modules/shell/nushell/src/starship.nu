## STARSHIP SPECIFIC (from upstream)

let starship_cache = ($"($env.XDG_CACHE_HOME)/starship" | path expand)
if not ($starship_cache | path exists) {
  mkdir $starship_cache
}
# ^starship init nu | save --force $"($starship_cache | path expand)/init.nu"

$env.STARSHIP_SHELL = "nu"
$env.STARSHIP_SESSION_KEY = (random chars -l 16)
$env.PROMPT_MULTILINE_INDICATOR = (^starship prompt --continuation)

# Does not play well with default character module.
# TODO: Also Use starship vi mode indicators?
$env.PROMPT_INDICATOR = ""
$env.PROMPT_COMMAND = { ||
    # jobs are not supported
    let width = (term size).columns
    ^starship prompt $"--cmd-duration=($env.CMD_DURATION_MS)" $"--status=($env.LAST_EXIT_CODE)" $"--terminal-width=($width)"
}

# Whether we have config items
let has_config_items = (not ($env | get -o config | is-empty))

$env.config = (if $has_config_items {
    $env.config | upsert render_right_prompt_on_last_line true
} else {
    {render_right_prompt_on_last_line: true}
})

$env.PROMPT_COMMAND_RIGHT = { ||
    let width = (term size).columns
    ^starship prompt --right $"--cmd-duration=($env.CMD_DURATION_MS)" $"--status=($env.LAST_EXIT_CODE)" $"--terminal-width=($width)"
}
