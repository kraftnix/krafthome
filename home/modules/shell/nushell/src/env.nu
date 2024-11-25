$env.NU_LIB_DIRS = [
  ($nu.config-path | path dirname | path join 'scripts')
]
$env.NU_PLUGIN_DIRS = [
  ($nu.config-path | path dirname | path join 'plugins')
]
