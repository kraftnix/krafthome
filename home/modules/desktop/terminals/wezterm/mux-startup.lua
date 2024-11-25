-- Docs: https://wezfurlong.org/wezterm/config/lua/mux-events/mux-startup.html
--
local wezterm = require 'wezterm'
local mux = wezterm.mux

-- this is called by the mux server when it starts up.
-- It makes a window split top/bottom
wezterm.on('mux-startup', function()
  local tab, pane, window = mux.spawn_window { workspace = 'home-infra' }
  local tab, pane, window = mux.spawn_window { workspace = 'projects' }
  local tab, pane, window = mux.spawn_window { workspace = 'misc' }
  local tab, pane, window = mux.spawn_window { workspace = 'remote', cwd = '~/notes' }
  mux.set_active_workspace('main')
end)
