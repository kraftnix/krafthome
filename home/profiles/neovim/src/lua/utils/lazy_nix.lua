local M = {}

local log = {
  info = vim.print,
  error = vim.print,
  warn = vim.print,
}

M.nixplugdir = '~/.config/nvim/nix-plugins/'

-- transforms `project/name` -> `name`
M.NameFromRepo = function (repo)
  return repo:match('/(.-)$')
end

---Function to calculate the Levenshtein distance between two strings
---@param str1 string
---@param str2 string
---@return integer distance
M.levenshtein = function(str1, str2)
  -- Initialize a matrix to store the distances between substrings
  local matrix = {}

  -- Initialize the first row and column of the matrix
  for i = 0, #str1 do
    matrix[i] = {[0] = i}
  end
  for j = 0, #str2 do
    matrix[0][j] = j
  end

  -- Loop through the strings and fill in the matrix
  for i = 1, #str1 do
    for j = 1, #str2 do
      local cost = (str1:sub(i, i) == str2:sub(j, j) and 0 or 1)
      matrix[i][j] = math.min(matrix[i-1][j] + 1, matrix[i][j-1] + 1, matrix[i-1][j-1] + cost)
    end
  end

  -- Return the final value in the matrix (the distance between the two strings)
  return matrix[#str1][#str2]
end

---Returns file name from a path
---@param path string
---@return string file_name
M.get_file_name = function (path)
  local split_strings = vim.fn.split(path, "/")
  return split_strings[#split_strings]
end

---Sanity check for LazyNix integration
---@param opts table
M.check_missing_nix_plugin = function(opts)
  local nix_plugin_path = vim.fn.expand(opts.dir)
  local exists = (1 == vim.fn.isdirectory(nix_plugin_path))
  if not exists then
    -- lets check for similarly named plugins in nix dir
    local nix_plugin_file_name = M.get_file_name(nix_plugin_path)
    local nix_plugins = vim.fn.readdir(vim.fn.expand(M.nixplugdir))
    local possible_matches = vim.iter(nix_plugins):map(function (possible_match)
      return (M.levenshtein(nix_plugin_file_name, possible_match)) < 2
    end):totable()
    local err_msg = ""
    local plugin_name = opts[1]
    -- if we find a close match
    if #possible_matches > 0 then
      -- create a nice error msg
      local first_match = possible_matches[1]
      local extra_msg = string.format([[
    You can correct this by setting the `nix_name` field to the entry in `~/.config/nvim/nix-plugins`,

    i.e. { '%s', nix_name = '%s' }
      ]], plugin_name, first_match)
      if #possible_matches > 1 then
        -- unlikely case, but create a different error message when multiple matches are found
        extra_msg = string.format([[
    Found multiple possible matches for this name mismatch.

    matches: %s

    Please check the correct plugin, and set the correct name in `nix_name`,

    i.e. { '%s', nix_name = '%s' }
      ]], vim.inspect(possible_matches), plugin_name, nix_plugin_file_name)
      end
      -- final error msg
      if not (type(first_match) == "string") then
        log.error("Problem with type of first_match: " .. type(first_match))
        first_match = "<error on first_match>"
      end
      err_msg = string.format([[

    Nix Plugin (%s) not found at path (%s).
    Your Nix Plugin is probably misnamed.

    Found   : %s
    Expected: %s

    %s
      ]], plugin_name, opts.dir, M.nixplugdir .. first_match, opts.dir, extra_msg)
    else
      -- otherwise the plugin is likely completely missing
      err_msg = string.format([[

    Nix Plugin (%s) not found at path (%s).

    Either add the plugin to `programs.neovim-lazy.plugins` and rebuild or use
    `lazy.nvim` to install by setting `nix_disable = true` in the offending plugin. i.e.
        { '%s', nix_disable = true }
      ]], opts[1], opts.dir, plugin_name)
    end
    if not exists then
      log.error(err_msg)
      assert(false, err_msg)
    end
  end
end

---@class LazyNixPluginSpec : LazyPluginSpec
---@field nix_disable? boolean
---@field nix_name? string
---@field dependencies? string[]|LazyNixPluginSpec[]
local LazyNixPluginSpec = {}

---Extends a LazyPluginSpec to use a Nix directory as its source instead
---of downloading the plugin via Lazy
---@param opts LazyNixPluginSpec extended LazyPluginSpec
---@return LazyPluginSpec # final Lazy Plugin spec
M.NixPlugin = function (opts)
  local nix_enabled = not opts.nix_disable
  local not_explicit_disable = not (opts.enabled == false)
  if opts.dir then
    log.info('Loading local plugin ', opts.dir)
    return opts
  elseif nix_enabled and not_explicit_disable then
    local nix_name = opts.nix_name or M.NameFromRepo(opts[1])
    if not nix_name then
      log.error('Missing `nix_name` from:', opts)
    end
    opts.dir = M.nixplugdir .. nix_name
    -- we must add nix dependencies or mismatches occur if a plugin is disabled
    -- and specifies dependecies that are used elsewhere (that are not disabled)
    if opts.dependencies ~= nil then
      opts.dependencies = M.mapNixPlugin(opts.dependencies)
    end
    M.check_missing_nix_plugin(opts)
  end
  return opts
end

---Maps a list of NixLazyPlugin -> LazyPluginSpec
---@param plugins LazyNixPluginSpec[] list of NixLazyPluginSpec
---@return LazyPluginSpec[] # final Lazy Plugin spec
M.mapNixPlugin = function (plugins)
  return vim.tbl_map(function (plugin)
    if type(plugin) == "string" then
      plugin = { plugin }
    end
    return M.NixPlugin(plugin)
  end, plugins)
end

return M
