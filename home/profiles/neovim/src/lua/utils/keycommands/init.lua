local log = require("plenary.log").new({ plugin = "KeyCommands", level = "info", use_console = 'async', use_quickfix = false, })

local class = require 'utils.vendor.middleclass'

require 'utils.keycommands.models'

---Maps a list-like set of classes with a `toTable()` method to a list of tables
---@param tables any[] must have a `toTable()` method
---@return table[]
local function mapToTables(tables)
  return vim.tbl_map(function (v)
    return v:toTable()
  end, tables)
end

--- Key Commands description
---@class KeyCommands
---@field keycommands KeyCommand[]
---@field groups table<string, KeyGroup>
KeyCommands = class('KeyCommands')
function KeyCommands:initialize(keycommands, groups)
  self.keycommands = keycommands or {}
  self.groups = groups or {}
end
function KeyCommands.log(level, ...)
  log[level](...)
end
function KeyCommands:toTable()
  return {
    keycommands = mapToTables(self.keycommands),
    groups = mapToTables(self.groups),
  }
end
function KeyCommands:__tostring()
  return vim.fn.json_encode(self:toTable())
end

--- Parses and groups `keycommands` field from Lazy
---@param force_reload? boolean reloads lazy plugins (doesn't reload keymaps)
---@return KeyCommands
function KeyCommands:parseFromLazy(force_reload)
  if self.keycommands == nil or force_reload then
    log.debug('Initialing KeyCommands (from lazy config).')
    self:initialize()
  else
    log.debug('Returning existing KeyCommands config.')
    log.debug(self:toTable())
    return self
  end

  local lazy_avail, lazy = pcall(require, "lazy")
  if not lazy_avail then return {} end

  local lazy_plugins = lazy.plugins()

  vim.iter(lazy_plugins)
    :filter(function (plugin)
      return plugin.keycommands_meta or plugin.keycommands
    end)
    :map(function (plugin)
      local meta = plugin.keycommands_meta
      if meta then
        plugin.group = self:insertGroup(KeyGroup:parseFromLazy(meta, plugin.name), false, plugin)
        plugin.default_group = meta.default_group or plugin.group:getName()
      end
      return plugin
    end)
    :map(function (plugin)
      if not plugin.group then
        local group = self:insertGroup(KeyGroup:initEmptyFromLazy(plugin.name), true)
        if group then
          plugin.group = group
          plugin.default_group = plugin.group:getName()
        end
      end
      return plugin
    end)
    :map(function (plugin)
      local keycommands = plugin.keycommands or {}
      return vim.iter(keycommands):map(function(keyconf)
        local keycommand = KeyCommand:parse(keyconf)
        -- handle overriden group
        if keycommand.group ~= '' then
          self:insertGroup(KeyGroup:initEmptyFromLazy(keycommand.group), true)
        else
          keycommand.group = plugin.default_group
        end
        -- default opts are local within plugin
        keycommand:applyDefaultOpts(plugin.group.default_opts)
        return self:insertKeycommand(keycommand.group, keycommand)
      end)--:totable()
    end)--:fold({}, flatten)

  -- for _, plugin_config in ipairs(lazy_plugins) do
  --   local meta = plugin_config.keycommands_meta
  --   local main = require("lazy.core.loader").get_main(plugin_config) or plugin_config.name
  --   local group = {}
  --   if meta then
  --     group = self:insertGroup(KeyGroup:parseFromLazy(meta, main))
  --   else
  --     group = self:insertGroup(KeyGroup:initEmptyFromLazy(main))
  --   end
  --   local keys = plugin_config.keycommands
  --   if keys then
  --     for _, keyconf in ipairs(keys) do
  --       local keycommand = KeyCommand:parse(keyconf)
  --       -- default opts are local within plugin
  --       if meta then
  --         keycommand:applyDefaultOpts(group.info.default_opts)
  --       end
  --       kcs[main] = keycommand
  --     end
  --   end
  -- end
  -- for plugin, keycommand in pairs(kcs) do
  --   local group = self:getGroup(keycommand.group)
  --   -- handle overriden group
  --   if keycommand.group ~= '' then
  --     if not self:checkExists(keycommand.group) then
  --       self:insertGroup(KeyGroup:initEmptyFromLazy(keycommand.group))
  --     end
  --   end
  --   lazy_commands[plugin] = keycommand
  -- end
  --
  -- local flattened_commands = {}
  -- for _, commands in pairs(lazy_commands) do
  --   for _, keycommand in ipairs(commands) do
  --     table.insert(flattened_commands, keycommand)
  --     self:insertKeycommand(keycommand.group, keycommand)
  --   end
  -- end

  -- self.keycommands = flattened_commands
  return self
end

---Insert group into group list, will override values and warn if already exists.
---@param key_group KeyGroup keygroup to insert
---@param ignore_existing? boolean when true, attempts to insert on existing groups are ignored (default: false)
---@param plugin?
---@return KeyGroup|nil # same keygroup passed in or nil if insert group is not inserted/already exists
function KeyCommands:insertGroup(key_group, ignore_existing, plugin)
  ignore_existing = ignore_existing or false
  local group = key_group:getName()
  local group_exists = self:checkExists(group)
  if not group_exists then
    self.groups[key_group:getName()] = key_group
  else
    if ignore_existing then
      return nil
    else
      local msg = string.format([[
Attempting to override existing [%s] in %s:
%s
<----> with <---->
%s
]], group, vim.inspect(plugin), self:getGroup(group), key_group)
      log.error(msg)
      assert(false, msg)
    end
  end
  return key_group
end

---Get the group
---@param group string
---@return KeyGroup
function KeyCommands:getGroup(group)
  -- self:checkAndPrint(group)
  return self.groups[group]
end

---Check if the group exists
---@param group string
---@return boolean
function KeyCommands:checkExists(group)
  return self.groups[group] ~= nil
end

---Checks if the group exists and prints to error log if not.
---@param group string
---@return true|false
function KeyCommands:checkAndPrint(group)
  local exists = self:checkExists(group)
  if not exists then
    log.error('Group (', group, ') missing:', self:toTable())
  end
  return exists
end

---Insert a keycommand into a group.
---Does not error when group is missing, only reports an error.
---@param group string group name
---@param keycommand KeyCommand
function KeyCommands:insertKeycommand(group, keycommand)
  if self:checkExists(group) then
    return self:getGroup(group):insertCommand(keycommand)
  else
    log.error('Tried to insert keycommand into missing group '..group..':', keycommand)
  end
end

---Get keycommands in specified group
---@param group string|nil group name
---@return KeyCommand[]
function KeyCommands:getKeycommands(group)
  if group then
    return self:getGroup(group).keycommands
  end
  return self.keycommands
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

---Returns true if map is et
---@param keymap KeyCommand
---@return boolean
function KeyCommands.filterNilMap(keymap)
  return keymap.map ~= nil
end

function getKeycommandKeymaps(keycommand)
  local kc = keycommand
  return vim.iter(kc.modes):map(function (mode)
    return KeycommandKeymap(mode,kc.map,kc.cmd,kc.opts)
  end):totable()
end

--- Returns the keymapps that can be set by `vim.api.nvim_set_keymap`
--- By default all keymaps are return
--- If a `group` is specified, then only keymaps of that group are returned.
---@param group? string|nil option group name to select keymaps from
---@return KeycommandKeymap[]
function KeyCommands:getKeymaps(group)
  local keycommands = self.keycommands
  if group then
    keycommands = self:getKeycommands(group)
  end

  -- local keymaps = {}
  -- vim.tbl_map(function (keycommand)
  --   local keymap = keycommand:getKeymap()
  --   for _, mode in ipairs(keymap.modes) do
  --     if keymap.map ~= nil then
  --       keymaps[#keymaps+1] = KeycommandKeymap(mode,keymap.map,keymap.cmd,keymap.opts)
  --     end
  --   end
  -- end, keycommands)
  local keymaps = vim.iter(keycommands)
    :filter(KeyCommands.filterNilMap)
    :map(getKeycommandKeymaps)
    :fold({}, flatten)
  return keymaps
end

--- Sets neovim keymaps
function KeyCommands:setKeymaps()
  for _, keymap in pairs(self.getKeymaps()) do
    keymap:set_keymap()
  end
end

---Prints from KeyCommands based on type provided
---@param t string
---@param printfunc function|nil
function KeyCommands:print(t, printfunc)
  printfunc = printfunc or print
  local values = {}
  if t == 'commands' then
    values = self:getCommands()
  elseif t == 'keymaps' then
    values = self:getKeymaps()
  elseif t == 'keycommands' then
    values = self.keycommands
  elseif t == 'legendary-cmds' then
    values = self:getLegendaryCommands()
  elseif t == 'legendary-keymaps' then
    values = self:getLegendaryKeymaps()
  elseif t == 'groups' then
    values = self.groups
  else
    printfunc('type '..t..' not supported')
  end
  vim.tbl_map(function (v)
    printfunc(v)
  end, values)
end

--- Sets neovim user commands
function KeyCommands:setUserCommands()
  vim.tbl_map(function (command)
    command:setCommand()
  end, self:getCommands())
end

---Returns Commander compatible commands (that can be added via commander.add)
---@return table[]
function KeyCommands:getCommanderCommands()
  return vim.tbl_map(function (command)
    return {
      desc = command.opts.desc,
      ":"..command.name,
    }
  end, self:getCommands())
end

--- # Returns **Commander** compatible commands (that can be added via commander.add)
---@return {desc: string, cmd: string|function, keys: table}[] list of keymaps
function KeyCommands:getCommanderKeymaps()
  return vim.tbl_map(function (keymap)
    return {
      desc = keymap.opts.desc,
      cmd = keymap.cmd,
      keys = keymap
    }
  end, self:getKeymaps())
end

--- Sets up commands + keymaps in Commander plugin
function KeyCommands:setupCommander()
---@diagnostic disable-next-line: undefined-field
  require('commander').add(
    self:getCommanderCommands(),
    { show = true, set = false }
  )
---@diagnostic disable-next-line: undefined-field
  require('commander').add(
    self:getCommanderKeymaps(),
    { show = true, set = false }
  )
end

---Returns Commander compatible commands (that can be added via commander.add)
---@return table[]
function KeyCommands:getLegendaryCommands()
  return vim.tbl_map(function (command)
    local final = {
      ":"..command.name,
      command.cmd
    }
    command.name = nil
    command.cmd = nil
    return vim.tbl_extend('force', final, command.opts)
  end, self:getCommands())
end

---Fetches groups
---@param include_all? boolean include groups without any keycommands are included (defaults to false)
---@return Iter<KeyGroup> group_iterator # call totable() to get a table
function KeyCommands:getGroups(include_all)
  include_all = include_all or false
  return vim.iter(self.groups)
    :filter(function (_, keygroup)
      return include_all or (not vim.tbl_isempty(keygroup.keycommands))
    end)
end

---# Returns Legendary Keymaps with grouping inferred from @KeyCommands
---@return {itemgroup: string, icon: string, description: string, keymaps: table}[] LegendaryKeyItem list of keymaps
function KeyCommands:getLegendaryKeymaps()
  local groups = self:getGroups()
  -- log.error(groups:totable())
  return groups
    :map(function (_, keygroup)
      -- log.error(keygroup)
      local keymaps = vim.iter(keygroup.keycommands)
        :filter(KeyCommand.hasKeymap)
        :map(KeyCommand.toKeymapLegendary)
        :totable()
      return {
        itemgroup = keygroup.group_name,
        icon = keygroup.icon,
        description = keygroup.description,
        keymaps = keymaps,
      }
    end):totable()

end

--- Sets up commands + keymaps in Commander plugin
function KeyCommands:setupLegendary()
  -- require('commander').add(self:getCommanderCmds(), { show = true, set = false })
end

-- KeyCommand.static.example_key_commands = {
--   {
--     '<leader>fnpe',
--     function()
--       print('hello world!')
--     end,
--     'Search nixpkgs',
--     'NixPkgsSearch',
--     'Nix'
--   }
-- }
-- KeyCommand.static.example = {
--   '<leader>fhe',
--   function()
--     print('hello world!')
--   end,
--   'Hello world description',
--   'ExampleHellowWorld',
--   'Example'
-- }
--

return KeyCommands


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
