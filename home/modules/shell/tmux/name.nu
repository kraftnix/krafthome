const sep = "____"
const args = [ window_index pane_pid client_session pane_current_command pane_current_path ]

def splitArgs [ ...args ] {
  split column $sep ...$args
}

# gets variables as defined in [FORMATS](https://man.openbsd.org/tmux.1#FORMATS)
def getTmux [ ...args ] {
  tmux display-message -p ($args | each {|| $"#{($in)}"}| str join $sep) | splitArgs ...$args
}

let glyphs = (cat ~/.config/tmux/glyphnames.json | from json | transpose name | flatten)

def override [ cmd ] {
  {
    nvim: neovim
    ssh: md-ssh
  } | get -i $cmd | default $cmd
}

def main [ matchString? : string ] {
  # echo Running name.nu with $nastr "\n" | str join " " | save -a ~/.local/state/tmux/name-nu.log
  let t = (if $matchString != "" {
    echo Using passed in matchString ($matchString) "\n" | str join " " | save -a ~/.local/state/tmux/name-nu.log
    $matchString | splitArgs ...$args
  } else {
    echo Getting own tmux from args ($args | to json -r) "\n" | str join " " | save -a ~/.local/state/tmux/name-nu.log
    getTmux ...$args
  } | first)
  # let t = ($nastr | splitArgs ...$args | first)
  let parent = ($t.pane_current_path | path parse | get stem)
  let number = ($t.window_index | str replace "@" "" | str trim)
  let cmd = ($t.pane_current_command)
  # $"($number) ($parent): ($cmd)"
  let pid = ($t.pane_pid)
  let info = (ps -l | find $pid)
  echo Parsed args: ($t | to json -r) "\n" | str join " " | save -a ~/.local/state/tmux/name-nu.log
  echo Info: ($info | to json -r) "\n" | str join " " | save -a ~/.local/state/tmux/name-nu.log
  let cmdtext = (if $cmd =~ nvim {
    "nvim"
  } else if $cmd =~ "-zsh" {
    "zsh"
  } else if $cmd =~ "ssh" {
    $"($info.command | last | str replace 'ssh ' '')"
  } else {
    $info.command | last | default $cmd
  } | split chars | take 20 | str join)
  let maybeGlyph = ($glyphs | find (override $t.pane_current_command) | first | default {char: $cmdtext} | get char)
  echo Maybe Glyph: ($maybeGlyph) "\n" | str join " " | save -a ~/.local/state/tmux/name-nu.log
  if $cmd =~ ssh {
    $"($maybeGlyph) reset) ($cmdtext | default 'none')"
  } else {
    $"($parent):($maybeGlyph) ($cmdtext | default 'none')"
  }
}
