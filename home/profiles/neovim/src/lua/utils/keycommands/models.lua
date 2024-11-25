local log = require("plenary.log").new({ plugin = "KeyCommands", level = "info", use_console = 'async', use_quickfix = false, })
local class = require 'utils.vendor.middleclass'

---Maps a list-like set of classes with a `toTable()` method to a list of tables
---@param tables any[] must have a `toTable()` method
---@return table[]
local function mapToTables(tables)
  return vim.tbl_map(function (v)
    return v:toTable()
  end, tables)
end

--- Key Command description
---@class KeyCommand
---@field map string mapping
---@field cmd string|function function/command to run
---@field desc string description
---@field name string command name (optional)
---@field opts table keymap opts (merged default_opts)
---@field group string group name
---@field is_nvim_command boolean short-hand which prevents auto-wrapping `<cmd>cmd<cr>` when `cmd` is a string
---@field cmd_gen_skip boolean do not generate a user command even when command name is specified
---@field modes string|string[] keymap modes to apply to
KeyCommand = class('KeyCommand')
function KeyCommand:initialize(map, cmd, desc, name, opts, group, modes, is_nvim_command, cmd_gen_skip)
  self.map = map
  self.cmd = cmd
  self.desc = desc
  self.name = name
  self.opts = opts
  self.group = group
  self.is_nvim_command = is_nvim_command or false
  self.cmd_gen_skip = cmd_gen_skip or false
  self.modes = modes
  if type(modes) == 'string' then
    self.modes = {modes}
  end
end
function KeyCommand:toTable()
  return {
    map = self.map,
    cmd = self.cmd,
    desc = self.desc,
    name = self.name,
    opts = self.opts,
    group = self.group,
    modes = self.modes,
    is_nvim_command = self.is_nvim_command,
    cmd_gen_skip = self.cmd_gen_skip ,
  }
end

function KeyCommand:toKeymapLegendary()
  return {
    self.map,
    (vim.iter(self.modes):fold({}, function (acc, item)
      acc[item] = self.cmd
      return acc
    end)),
    -- self.cmd,
    description = self.desc,
    opts = self.opts,
  }
end

---Returns true if has a non-null map
---@return boolean
function KeyCommand:hasKeymap()
  return self.map ~= nil
end

---Returns a string (JSON encoded) of the fields
---@return string|nil
function KeyCommand:__tostring()
  return vim.fn.json_encode(self:toTable())
end

---Requires KeyCommand object to already be set up
---@param default_opts table
function KeyCommand:applyDefaultOpts(default_opts)
  self.opts = vim.tbl_deep_extend('force', default_opts, self.opts)
end

--- Parses a table into a KeyCommand object
---@param tbl table
---@return KeyCommand
function KeyCommand:parse(tbl)
  log.debug('Parsing KeyCommand from table: ', tbl)
  local map = tbl.map or tbl[1]
  local cmd = tbl.cmd or tbl[2]
  local desc = tbl.desc or tbl[3] or ''
  local name = tbl.name or tbl[4]
  local opts = tbl.opts or tbl[5] or {}
  local group = tbl.group or tbl[6] or ''
  local is_nvim_command = tbl.is_nvim_command
  local cmd_gen_skip = tbl.cmd_gen_skip
  local modes = opts.modes or opts.mode or {'n'}

  vim.validate({
    map = { map, { 'string' }, true },
    cmd = { cmd, { 'string', 'function' } },
    desc = { desc, { 'string' }, true },
    name = { name, { 'string' }, true },
    opts = { opts, { 'table' }, true },
    group = { group, { 'string' }, true },
    is_nvim_command = { is_nvim_command, { 'boolean' }, true },
    cmd_gen_skip = { cmd_gen_skip, { 'boolean' }, true },
    modes = { modes, { 'table' }, true },
  })

  if type(cmd) == "string" then
    if not is_nvim_command then
      cmd = "<cmd>"..cmd.."<cr>"
    end
  elseif cmd == nil then
    log.error('Unexpected nil command in object', tbl)
  elseif type(cmd) ~= 'function' then
    log.error('Incorrect type given for keymap end', type(cmd), tbl)
    assert(false, 'Incorrect type given for keymap end', type(cmd), tbl)
  end

  local kc = KeyCommand(map, cmd, desc, name, opts, group, modes, is_nvim_command, cmd_gen_skip)
  log.debug('Finished Parsing KeyCommand: ', kc:toTable())
  return kc
end

---Filters a table based on key names.
---Filters keys from `to_filter` contained in the `keys_to_remove` list
---@param to_filter table
---@param keys_to_remove string[]
---@return table
local function filter_args(to_filter, keys_to_remove)
  local result = {}
  for key, val in pairs(to_filter) do
      if not vim.tbl_contains(keys_to_remove, key) then
          result[key] = val
      end
  end
  return result
end

-- `cmd_gen_skip`: used when the cmd already exists, skips creation in `vim.nvim_create_user_command`
--                 commander picks up the command, using the `cmd` field (string expected) as the command name
--- @param km table
--- @return table
function KeyCommand.stripMetaKey(km)
  return filter_args(km, {
    'name',
    'modes',
    'map',
    'cmd',
    'group',
    'is_nvim_command',
    'opts',
    'cmd_gen_skip',
    'meta',
  })
end

---# Parses a neovim compatible keymap from a KeyCommand
---@return {cmd: string|function, map: string, modes: string[], opts: table} # keymap
function KeyCommand:getKeymap()
  local final = {}
  final.cmd = self.cmd
  final.modes = self.modes or {'n'}
  final.map = self.map
  final.opts = KeyCommand.stripMetaKey(self.opts)
  if self.desc ~= '' then
    final.opts.desc = self.desc
  end
  return final
end

local function stringNotEmpty(val)
  return not (val == nil or val == '')
end

--- Keymap: Neovim native keymap object
---@class KeycommandKeymap
---@field mode string
---@field map string
---@field cmd string
---@field opts table
KeycommandKeymap = class('KeycommandKeymap')
function KeycommandKeymap:initialize(mode, map, cmd, opts)
  vim.validate({
    mode = { mode, {'string'}, true },
    map = { map, stringNotEmpty, 'Map in Keymap is empty' },
    cmd = { cmd, stringNotEmpty, 'Cmd in Keymap is empty' },
    opts = { opts, {'table'}, true },
  })
  self.mode = mode or 'n'
  self.map = map
  self.cmd = cmd
  self.opts = opts or {}
end

function KeycommandKeymap:toTable()
  return {
    mode = self.mode,
    map = self.map,
    cmd = self.cmd,
    opts = self.opts,
  }
end

-- Sets the keymap with `nvim_set_keymap`
function KeycommandKeymap:set_keymap()
  local cmd = self.cmd
  local opts = self.opts
  if type(cmd) == 'function' then
    opts.callback = cmd
    cmd = ''
  end
  vim.api.nvim_set_keymap(self.mode, self.map, cmd, opts)
end
---Returns a string (JSON encoded) of the fields
---@return string|nil
function KeycommandKeymap:__tostring()
  return vim.fn.json_encode(self:toTable())
end

---concats two lists together, second argument can just be a value
---useful with user of `vim.iter()` to flatten list-like nested iterators
---@param acc any[] initial list (of `<A>`)
---@param maybe_list any|any[] maybe a list, or a value (of `<A>`)
---@return any[] flattened_list
flatten = function (acc, maybe_list)
  if type( maybe_list ) == 'table' then
    for _, item in pairs(maybe_list) do
      acc[#acc+1] = item
    end
  else
    acc[#acc+1] = maybe_list
  end
  return acc
end

function getKeycommandKeymaps(keycommand)
  local kc = keycommand
  return vim.iter(kc.modes):map(function (mode)
    return KeycommandKeymap(mode,kc.map,kc.cmd,kc.opts)
  end):totable()
end

--- Keymap: Neovim native keymap object
---@class KeycommandUserCommand
---@field name string
---@field cmd string|function
---@field opts table
KeycommandUserCommand = class('KeycommandUserCommand')
function KeycommandUserCommand:initialize(name, cmd, opts)
  vim.validate({
    name = { name, function (n)
      return n ~= nil and n ~= ""
    end, 'Name must not be nil or an empty string for:\n' .. vim.inspect(cmd, opts)},
    cmd = { cmd, { 'function', 'string' } },
    opts = { opts, { 'table' }, true }
  })
  self.name = name
  self.cmd = cmd
  self.opts = opts or {}
end
function KeycommandUserCommand:setCommand()
  vim.api.nvim_create_user_command(self.name, self.cmd, self.opts)
end

---KeycommandUserCommand table version
---@return {name: string, cmd: string|function, opts: table}[] # list of keymaps
function KeycommandUserCommand:toTable()
  return {
    name = self.name,
    cmd = self.cmd,
    opts = self.opts,
  }
end
---Return json encoded version
---@return string|nil
function KeycommandUserCommand:__tostring()
  return vim.fn.json_encode(self:toTable())
end

---@class KeyGroup
---@field keycommands KeyCommand[]
---@field group_name string
---@field description string
---@field icon string
---@field default_opts table
---@field source string
KeyGroup = class('KeyGroup')
function KeyGroup:initialize(group_name, description, icon, default_opts, source)
  self.group_name = group_name
  self.description = description
  self.icon = icon
  self.default_opts = default_opts
  self.source = source
  self.keycommands = {}
end
function KeyGroup:toTable()
  return {
    group_name = self.group_name,
    description = self.description,
    icon = self.icon,
    default_opts = self.default_opts,
    source = self.source,
    keycommands = mapToTables(self.keycommands),
  }
end
---Returns a string (JSON encoded) of the fields
---@return string|nil
function KeyGroup:__tostring()
  return vim.fn.json_encode(self:toTable())
end

---Generates a simple group from only lazy plugin name
---@param name string plugin name (lazy.main)
---@param source string|nil normally plugin name
---@return KeyGroup
function KeyGroup:initEmptyFromLazy(name, source)
  return self(name, '', '', {}, source or name)
end

---Parses `keycommands_meta` field in a lazy plugin
---@param meta table contents of field
---@param source string plugin name (lazy.main)
---@return KeyGroup
function KeyGroup:parseFromLazy(meta, source)
  return self(
    meta.group_name or source,
    meta.description or '',
    meta.item or '',
    meta.default_opts or {},
    source
  )
end

function KeyGroup:getName()
  return self.group_name
end

-- function KeyGroup:get_default_opts()
--   return self.info.default_opts
-- end

---insert the keycommand into the keycommands table and returns the insert keycommand
---@param keycommand KeyCommand
---@return KeyCommand
function KeyGroup:insertCommand(keycommand)
  table.insert(self.keycommands, keycommand)
  return keycommand
end

return {
  KeycommandKeymap = KeycommandKeymap,
  KeycommandUserCommand = KeycommandUserCommand,
  KeyCommand = KeyCommand,
  KeyGroup = KeyGroup,
}

-- -- string cmd automatically means telescope
-- KeyCommand.map_key_old = function(km)
--   if type(km.cmd) == "string" then
--     local last = "<cr>"
--     if km.is_nvim_command then
--       last = ""
--     end
--     km.cmd = ":Telescope "..km.cmd..last
--     -- cmd = function ()
--     --   require('telescope.builtin')[vim.fn.copy(cmd)]()
--     -- end
--   elseif type(km.cmd) == "function" then
--     km.callback = km.cmd
--     km.cmd = ''
--   elseif km.cmd == nil then
--     KeyCommand.print('Unexpected nil command in object', km)
--   else
--     assert(false, KeyCommand.print('Incorrect type given for keymap end', type(km.cmd), km))
--   end
--   km.modes = km.modes or {'n'}
--   local final = {
--     modes = km.modes,
--     map = km.map,
--     cmd = km.cmd,
--   }
--   final.opts = KeyCommand.stripMetaKey(km)
--   return final
-- end
