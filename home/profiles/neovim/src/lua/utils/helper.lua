local legendary = require 'utils.vendor.legendary'
local lazy_nix = require 'utils.lazy_nix'
local M = {}


---concats two lists together, second argument can just be a value
---useful with user of `vim.iter()` to flatten list-like nested iterators
---@param acc any[] initial list (of `<A>`)
---@param maybe_list any|any[] maybe a list, or a value (of `<A>`)
---@return any[] flattened_list
M.flatten = function (acc, maybe_list)
  if type( maybe_list ) == 'table' then
    for _, item in pairs(maybe_list) do
      acc[#acc+1] = item
    end
  else
    acc[#acc+1] = maybe_list
  end
  return acc
end

---@param strings string|string[] string or list of strings
---@param sep string defaults to newline (" ")
function M.concatStringsSep(strings, sep)
  if type(strings) == "string" then
    return strings
  end
  sep = sep or " "
  return vim.iter(strings):fold('', function(full, str)
      return full..sep..str
    end)
end

---remove terminal escape characters from string
---@param string string
---@return string string
function M.removeEscapes(string)
  string:gsub("\27%[%d+m", "") -- Remove escape character
  return string
end

M.NixPlugin = lazy_nix.NixPlugin
M.mapNixPlugin = lazy_nix.mapNixPlugin

local log = {
  info = vim.print,
  error = vim.print,
  warn = vim.print,
}

---NOTE: vendored from legendary
---      this is stupid, but functions are cached in lua so can't be renamed
---Return a function which lazily `require`s a module and
---calls a function from it. Functions nested within tables
---may be accessed using dot-notation, i.e.
---`lazy_required_fn('module_name', 'some.nested.fn', some_argument)`
---@param module_name string The module to `require`
---@param fn_name string The table path to the function
---@param ... any The arguments to pass to the function
---@return function
M.lr = function (module_name, fn_name, ...)
  local args = { ... }
  return require('utils.vendor.legendary').lazy_required_fn(module_name, fn_name, unpack(args))
end
M.legendary = require('utils.vendor.legendary')
M.lazy_required_fn = M.legendary.lazy_required_fn
M.lazy = legendary.lazy
M.is_function = legendary.is_function

---Concatenates two list-like tables
---@param t1 any[]
---@param t2 any[]
function M.concat_tables(t1, t2)
  for _,v in ipairs(t2) do
    table.insert(t1, v)
  end
  return t1
end


---Follow ssh auth_sock
---@return string|nil
function M.get_ssh_auth_sock()
  local path = '~/.ssh/auth_sock'
  local ssh_auth_sock = vim.fn.system('readlink -f '..path)
  if not ssh_auth_sock then
    log.error('No SSH_AUTH_SOCK symlink found at '..path)
    return nil
  else
    ssh_auth_sock = ssh_auth_sock:gsub("[\n\r]", "")
    return "let $SSH_AUTH_SOCK = '"..ssh_auth_sock.."'"
  end
end

---Updates internal neovim SSH_AUTH_SOCK variable
function M.update_ssh_auth_sock()
  local cmd = M.get_ssh_auth_sock()
  if cmd then
    log.info('Updated SSH auth sock with cmd: ', cmd)
    vim.cmd(cmd)
  end
end

---add silent option to given keymap
---@param key {}
---@return {}
function M.mapSilent(key)
  key.opts = key.opts or {}
  key.opts.silent = true
  return key
end


-- returns directory of current buffer file
M.GetCurrDir = function ()
  file = vim.fn.expand("%")
  if M.StrEmpty(file) then
    return vim.fn.getcwd()
  else
    return vim.fn.system("dirname "..file):gsub("%s+", "")
  end
end

--- Return true if string is empty or nil
---@param string string
---@return boolean
M.StrEmpty = function (string)
  return string == nil or string == ""
end

--- returns directory of current buffer file
---@param cmd string
M.FmDir = function (cmd)
  local parent = M.GetCurrDir()
  vim.cmd (string.format(":%s %s", cmd, parent))
end

-- call fm-nvim on current directory
M.FmDirWrap = function (cmd)
  return function ()
    return M.FmDir(cmd)
  end
end

-- transforms `project/name` -> `name`
M.NameFromRepo = function (repo)
  return repo:match('/(.-)$')
end

---Returns the current directory
---@return string|string[]
M.get_current_buf_dir = function()
  return vim.fn.expand('%:p:h')
end

---Returns a lazily called telescope picker
---Special handling for `find_file`, `live_grep` and `grep_string` to use menufacture
---@param command string telescope command
---@param opts {} any extra opts for the telescope builtin call
---@return function # lazily called telescope picker
function M.tb(command, opts)
  if command == 'find_files' or command == 'live_grep' or command == 'grep_string' then
    return M.lazy_required_fn('telescope', 'extensions.menufacture.'..command, opts)
  else
    return M.lazy_required_fn('telescope.builtin', command, opts)
  end
end

---## Lazy Telescope wrapper function
---Provides easy `path` searching with expansion and integrates `menufacture` automatically
---@param cmd string any telescope command, special handling for [find_files, live_grep, grep_string]
---@param path string vim path string to search in, is expanded by vim.fn.expand() i.e. `'%:p:h'` for current buffer dir
---@param extra? table any extra options to pass into telescope
---@return function telescope_picker_func # lazily wrapped telescope picker
function M.tb_wrap(cmd, path, extra)
  extra = extra or {}
  local inferred = {}
  -- nested function for path expansion
  return function ()
    if cmd == 'live_grep' then
      inferred.search_dirs = { vim.fn.expand(path) }
    end
    local opts = vim.tbl_extend('force', {
      layout_strategy = 'vertical',
      cwd = vim.fn.expand(path),
    }, inferred, extra)
    -- get lazy func and call it instantly
    return M.tb(cmd, opts)()
  end
end

---Returns file name from a path
---@param path string
---@return string file_name
M.get_file_name = function (path)
  local split_strings = vim.fn.split(path, "/")
  return split_strings[#split_strings]
end

---adds a `cmd_gen_skip` field to the keycommand
---@param keycommand KeyCommand keycommand to exdtend
---@return KeyCommand
M.mapSkipGen = function (keycommand)
  if keycommand.opts then
    keycommand.opts = vim.tbl_deep_extend('force', keycommand.opts, { cmd_gen_skip = true })
  end
  return keycommand
end

M.make_telescope_command = function(opts)
  local mapping = opts[1] or opts.mapping
  local cmd = opts[2] or opts.f or opts.cmd
  if type(cmd) == "string" then
    local last = "<cr>"
    if opts.is_nvim_command then
      last = ""
    end
    cmd = ":Telescope "..cmd..last
    -- cmd = function ()
    --   require('telescope.builtin')[vim.fn.copy(cmd)]()
    -- end
  elseif type(cmd) == "function" then
    -- vim.print(cmd)
  else
    assert(false, vim.print('Incorrect type given for opt end', cmd, opts))
  end
  local desc = opts[3] or opts.desc or ""
  opts[1] = "<leader>"..mapping
  opts[2] = cmd
  -- opts[3] = 'n'
  opts.desc = desc
  opts.mode = 'n'
  opts[3] = nil
  opts.cmd = nil
  opts.f = nil
  if opts.is_nvim_command then
    opts.is_nvim_command = nil
    opts[1] = opts[2]
    opts[2] = nil
  end
  return opts
end

return M
