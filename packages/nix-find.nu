def main [ ] {
  print $"Run (ansi green)`nix-find --help`(ansi reset) for more info."
}

# returns the binary path of a command in your path (found using `which`)
def "main bin" [
  binary : string # name of binary in PATH
]: nothing -> string {
  let res = (which $binary)
  if $res == [ ] {
    print $"(ansi red)No binary found in path:(ansi reset) (ansi yellow)($binary)(ansi reset)"
    exit 1
  } else {
    $res | get 0.path | path expand
  }
}

# list system generations
def "main generations" [
  --all # return all generations found
  --number(-n): int = 8 # number of generations returned (default: 8)
]: nothing -> list<any> {
  let profiles = (ls /nix/var/nix/profiles | sort-by modified -r)
  if $all {
    $profiles
  } else {
    $profiles | first $number
  }
}

# switch to a numbered system generation
def "main generations switch" [
  generation: int # generation to swtich to
]: nothing -> nothing {
  let path = ($"/nix/var/nix/profiles/system-($generation)-link")
  if ($path | path exists) {
    run-external $"($path)/bin/switch-to-configuration" switch
  } else {
    print $"(ansi red)Did not find generation ($generation) in /nix/var/nix/profiles(ansi reset)"
  }
}
