-- From Legendary Toolbox
local Legendary = {}

---Return a function with statically set arguments.
---@param fn function The function to execute lazily
---@param ... any The arguments to pass to `fn` when called
---@return function
function Legendary.lazy(fn, ...)
  local args = { ... }
  return function()
    fn(unpack(args))
  end
end

function Legendary.is_function(a)
  if type(a) == 'function' then
    return true
  end

  local mt = getmetatable(a)
  if not mt then
    return false
  end

  return not not mt.__call
end

local function is_function(a)
  if type(a) == 'function' then
    return true
  end

  local mt = getmetatable(a)
  if not mt then
    return false
  end

  return not not mt.__call
end

---Return a function which lazily `require`s a module and
---calls a function from it. Functions nested within tables
---may be accessed using dot-notation, i.e.
---`lazy_required_fn('module_name', 'some.nested.fn', some_argument)`
---@param module_name string The module to `require`
---@param fn_name string The table path to the function
---@param ... any The arguments to pass to the function
---@return function
function Legendary.lazy_required_fn(module_name, fn_name, ...)
  local args = { ... }
  return function()
    local module = (_G['require'](module_name))
    if string.find(fn_name, '%.') then
      local fn = module
      for _, key in ipairs(vim.split(fn_name, '%.', { trimempty = true })) do
        fn = (fn)[key]
        if fn == nil then
          log.error('[legendary.nvim]: invalid lazy_required_fn usage: no such function path')
          return
        end
      end
      if not is_function(fn) then
        log.error('[legendary.nvim]: invalid lazy_required_fn usage: no such function path')
        return
      end
      local final_fn = fn
      final_fn(unpack(args))
    else
      local fn = module[fn_name]
      fn(unpack(args))
    end
  end
end

return Legendary
