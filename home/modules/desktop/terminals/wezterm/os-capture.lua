-- Found in: https://github.com/wez/wezterm/issues/2225
--
local io = require 'io';
local os = require 'os';

-- Captures output of an OS command to a string.
function os.capture(cmd, raw)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  if raw then return s end
  s = string.gsub(s, '^%s+', '')
  s = string.gsub(s, '%s+$', '')
  s = string.gsub(s, '[\n\r]+', ' ')
  return s
end

-- Boolean function that returns true of a string starts with the passed in argument.
local function starts_with(str, start)
  return str:sub(1, #start) == start
end
