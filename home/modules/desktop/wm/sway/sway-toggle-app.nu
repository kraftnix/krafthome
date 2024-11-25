# data structure
# tree
# |- nodes (screens) [0 is xwayland, 1 is your primary]
# |-- nodes (workspaces) [has `name` field for identification]
# |--- nodes :- this can keep nesting, children of workspace
def getTree [] {
  swaymsg -t get_tree | from json
}

# NOTE: this has false-positives
def appOpen [ name : string ] {
  (swaymsg -t get_tree | lines | where $it =~ $name | length) > 0
}

def getWorkspace [ name : string ] {
  getTree | get nodes.1.nodes | where name =~ $name
}

# toggles a marked app to/from its workspace
# mark and workspace must be same name
# extraOpts ex: 'resize set 1912 1043, move position 4 4'
def main [ name : string, extraOpts? ] {
  let name = ($name | into string)
  let workspace = (getWorkspace $name)
  if $workspace == [] {
    # send back to it's workspace
    swaymsg ($'[con_mark="($name)"] move to workspace ($name), floating disable')
  } else {
    # if in it's workspace, send to scratchpad + show
    let extraStr = (if $extraOpts == null { "" } else { $", ($extraOpts)" })
    swaymsg ($'[con_mark="($name)"] move to workspace current, move scratchpad, scratchpad show($extraStr)')
  }
}

# unused
def getMark [ tree mark ] {
  let len = ($tree | get marks | length)
  if $len == 0 {
    []
  } else {
    $tree.marks
  }
}

#def getMarks [ mark ] {
#  let tree = getTree
#  [
#    (getMark $tree $mark)
#    (getMark $tree.nodes)
#  ] | reduce {|it, acc| $acc | append $it)
#}
