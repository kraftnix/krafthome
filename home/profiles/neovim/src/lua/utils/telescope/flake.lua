local config = require("telescope.config").values
local entry_display = require("telescope.pickers.entry_display")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local previewers = require("telescope.previewers")
local sorters = require ("telescope.sorters")
local h = require 'utils.helper'

local M = {}

function M.containsUnderscoreAndNumber(string)
  local pattern = "%_[%d]+$" -- underscore followed by one or more digits at the end
  local match = string.match(string, pattern)
  return match ~= nil
end

local function trimFinalNewline(str)
  return string.gsub(str, "[\r\n]$", "")
end

function M.filter_dups(name)
  local pattern = ".+_[%d]+$" -- underscore followed by one or more digits at the end
  return not (string.match(name, pattern))
end

function M.readNode(name, opts)
  return {
    name = name,
    locked = opts.locked,
    original = opts.original,
    inputs = opts.inputs,
  }
end

--- Reads the `flake.lock` file from the `cwd` and returns all inputs
function M.readFlakeLock()
  local current_directory = vim.loop.cwd()
  local json_file = io.open(current_directory..'/flake.lock', 'r')
  if not json_file then
    vim.notify('File not found.', 'error')
    error('File not found')
    return ""
  end
  local json_content = json_file:read('*all')
  json_file:close()

  local json_table = vim.fn.json_decode(json_content)
  local final_table = vim.iter(json_table.nodes)
    :filter(M.filter_dups)
    :map(M.readNode)
    :totable()
  return final_table
end

-- results = { unpack(results, 1, 3) }
function M.stripFlakeOuputText(str)
  local marker = "updating lock file "
  local strippedStr = str:gsub(".-" .. marker, "")
  local ret = ""
  if strippedStr then
    ret = marker..strippedStr
  end
  return h.removeEscapes (ret:gsub("[^\r\n]+", function(line)
    if line:match("warning: Git tree ") and line:match("is dirty") then
      return ""
    else
      return line
    end
  end):gsub("\n\n", "\n"))
end

M.nuGetFlakeInputsCmd = [[
nu -c '
  let cmd = (do { ^nix flake info } | complete)
  if $cmd.exit_code == 0 {
    { stdout: ($cmd.stdout
        | do { ^sed -e `s/\x1b\[.\{1,5\}m//g` } # hacky remove control characters...
        | lines | str trim
        | filter {|| ($in | str starts-with "├") or ($in | str starts-with "└")) }
        | filter {|| not ($in | str contains "follows input ") }
        | str substring 12.. | str trim
        | parse "{input}: {url}"
        | transpose -r
        | get 0
      )
      exit_code: 0
      # stderr: $cmd.stderr
    } | to json
  } else {
    $cmd | to json
  }
'
]]

---@alias input string flake input name
---@alias flake_uri string flake uri
---@alias input_list table<input, flake_uri> list of flake inputs
---returns a table parsed from json of parsed updateable inputs
---@return {stdout: input_list, stderr: string, exit_code: number}
function M.getUpdateableInputs()
  local out = vim.fn.system(M.nuGetFlakeInputsCmd)
  out:gsub('\\\r', '') -- strip some ascii codes...
  local json = vim.fn.json_decode(out)
  return json
end

function M.filterUpdateable(results, updateable)
  if updateable.exit_code ~= 0 then
    vim.notify('Failed to find any update-able inputs, allowing all in flake.lock', 'warn')
    vim.notify(vim.inspect(updateable), 'warn')
    return results
  else
    local new_results = {}
    for name, url in pairs(updateable.stdout) do
      local res = vim.tbl_filter(function (val)
        return val.name == name
      end, results)[1]
      new_results[#new_results+1] = res
    end
    table.sort(new_results, function(a, b)
      local aLast = a.locked.lastModified
      local bLast = b.locked.lastModiifed
      if not bLast then
        return false
      elseif not aLast then
        return true
      end
      return aLast > bLast
    end)
    for i, res in ipairs(new_results) do
      res.sort_index = i
    end
    return new_results
  end
end

---Get name from selections
---@param entry table
---@return string input_name
local function getName(entry)
  return entry.name
end

---Generate --update-input args for an input
---@param input_name string input name
---@return string[] extra_args
local function getArgs(input_name)
  return { '--update-input', input_name }
end

--- handles output from flake update / lock update-input commands
--- sends messages via `vim.notify`
---@param inputNamesStr string|nil (optional) list of input string names
---@return fun(out: any, exit_code: number) exit_code_handler
function M.handleFlakeUpdateExit(inputNamesStr)
  inputNamesStr = inputNamesStr or ""
  inputNamesStr = inputNamesStr.."\n"
  return function(out, exit_code)
    local err = h.concatStringsSep(out:stderr_result(), "\n")
    local output = h.concatStringsSep(out:result(), "\n")
    if exit_code ~= 0 then
      vim.notify('Failed while running update command:\n'..err, 'error')
    elseif (string.find(output, 'Updated')) then
      vim.notify("Updates:"..inputNamesStr.."\n"..M.stripFlakeOuputText(output), 'warn')
    elseif (string.find(err, 'Updated')) then
      vim.notify("Updates:"..inputNamesStr.."\n"..M.stripFlakeOuputText(err), 'warn')
    else
      vim.notify(trimFinalNewline('No updates for:'..inputNamesStr), 'info')
    end
  end
end

--- Async Plenary job for running `nix flake lock {--update-input input} for the `inputs` list`
---@param inputs string|string[] string or list of strings
function M.updateFlakeLock(inputs)
  local Job = require 'plenary.job'
  local name_list = vim.iter(inputs):map(getName):totable()
  local inputNamesStr = h.concatStringsSep (name_list, '\n - ')
  local args = vim.iter(name_list):map(getArgs):fold({ 'flake', 'lock' }, h.flatten)
  return Job:new {
    command = "nix",
    args = args,
    on_start = function()
      vim.notify('Running flake lock update on: '..inputNamesStr, 'info')
    end,
    on_exit = M.handleFlakeUpdateExit(inputNamesStr)
  }
end

--- Async Plenary job for running `nix flake update`
function M.updateFlakeLockAll()
  local Job = require 'plenary.job'
  return Job:new {
    command = "nix",
    args = { 'flake', 'update' },
    on_start = function()
      vim.notify('Updating all inputs with `nix flake update`', 'info')
    end,
    on_exit = M.handleFlakeUpdateExit()
  }
end

---Returns a function that calls an async job for updating a flake lock inputs
---@param prompt_bufnr number
function M.update_input(prompt_bufnr)
  local action_state = require 'telescope.actions.state'
  local picker = action_state.get_current_picker(prompt_bufnr) -- picker state
  local selections = picker:get_multi_selection()
  if #selections < 2 then
    local entry = action_state.get_selected_entry()
    selections = { entry }
  end
  local async = require 'plenary.async'
  local build_job = async.void(function()
    M.updateFlakeLock(selections):start()
  end)
  return build_job()
end

--- Returns a function that calls an async job for updating all flake inputs
function M.update_all()
  local async = require 'plenary.async'
  local build_job = async.void(function()
    M.updateFlakeLockAll():start()
  end)
  return build_job()
end

--- Flake input picker mappings
function M.attach_mappings(prompt_bufnr, map)
  map("n", "<c-f><c-u>", M.update_input)
  map("i", "<c-f><c-u>", M.update_input)

  map("n", "<c-f><c-l>", M.update_all)
  map("i", "<c-f><c-l>", M.update_all)

  return true
end

--- Style for displayer/picker
function M.displayer()
  local items = {
    { width = 20 },
    { width = 50 },
    { width = 15 },
    { remaining = true },
  }
  return entry_display.create({
    separator = " ",
    items = items,
  })
end

function M.flakeUriNeat(name)
  local cmd = string.format([[
    nu -c '
    def trimUrlPath [ ] { $in.path | str replace / "" }
    def main [
      flakeStr : string # flake string to give suchas https://gitea.example.com/username/myrepo
    ] -> string {
      let url = ($flakeStr | url parse)
      if $url.scheme == ssh {
        mut portStr = ""
        if $url.port != "" {
          $portStr = (echo "(" $url.port ")" | str join "")
        }
        let path = ($url | trimUrlPath)
        echo $url.scheme $portStr @ $url.host : $path | str join ""
        # $"($url.scheme)($portStr)@($in.host):($path)"
      } else if ($url | get scheme) == https {
        let path = ($url | trimUrlPath)
        # $"($url.host):($path)"
        echo $url.host : $path | str join ""
      } else {
        $flakeStr
      }
    }
    main "%s"
    '
]], name)
  local out = vim.fn.system(cmd)
  return trimFinalNewline(out)
end

local function getRelativeTimeString(timestamp)
  local now = os.time()
  local difference = now - timestamp
  if difference < 60 then
    return "just now"
  elseif difference < 3600 then
    local minutes = math.floor(difference / 60)
    return minutes .. " minutes ago"
  elseif difference < 86400 then
    local hours = math.floor(difference / 3600)
    return hours .. " hours ago"
  else
    local days = math.floor(difference / 86400)
    return days .. " days ago"
  end
end

function M.make_display(entry)
  local display = {
    { entry.name },
    { entry.flake_uri, 'TelescopeBorder' },
    { entry.relative, 'TelescopeResultsTitle' },
    { entry.date, 'TelescopePromptTitle' },
  }
  return M.displayer()(display)
end

--- Returns a flake input picker
function M.flake_picker(opts)
  opts = opts or {}
  local updateable = M.getUpdateableInputs()
  local results = vim.iter(M.readFlakeLock())
    :filter(function (opts) return opts.name ~= 'root' end)
    :fold({}, function(acc, item)
      acc[#acc+1] = item
      return acc
    end)
  pickers.new(opts, {
    prompt_title = "Flake Inputs",
    finder = finders.new_table {
      -- results = results,
      results = M.filterUpdateable(results, updateable),
      entry_maker = function(entry)
        local lastMod = tonumber(entry.locked.lastModified)
        local date = tostring(os.date('%Y-%m-%d %H:%M', lastMod))
        local index = math.ceil(((os.time() - lastMod) / (60 * 60)))
        local flake_uri = 'undefined'
        if entry.original.url then
          flake_uri = M.flakeUriNeat(entry.original.url) or "failed neat"
        elseif entry.original.type == "github" then
          flake_uri = entry.original.type .. ":" .. entry.original.owner .. "/" .. entry.original.repo
        end
        -- vim.print(entry.name, tostring(index))
        return {
          value = entry,
          -- index = index,
          index = entry.sort_index, --doesnt' seem to work
          -- index = lastMod,
          flake_uri = flake_uri,
          name = entry.name,
          date = date,
          last_modified = lastMod,
          relative = getRelativeTimeString(lastMod),
          -- display = display,
          ordinal = entry.name,
          original = entry.original,
          locked = entry.locked,
          display = M.make_display,
        }
      end
    },
    -- sorter = config.generic_sorter(opts),
    sorter = sorters.fuzzy_with_index_bias(opts),
    -- sorting_strategy = 'ascending', -- required or first load preview breaks..
    sorting_strategy = 'descending',
    previewer = previewers.new_buffer_previewer {
      define_preview = function(self, entry, status)
        -- currently regrabs falke.lock...
        local cmd = { "nu", "-c", [[open flake.lock | from json | get nodes.]]..entry.name.." | table -ew 9999" }
        -- local cmd = { 'echo', vim.fn.json_encode(entry.value) }
        -- local cmd = { 'echo', vim.inspect(entry.value) }
        return require('telescope.previewers.utils').job_maker(
          cmd,
          self.state.bufnr,
          {
            mode = "append",
            callback = function(bufnr, content)
              if content ~= nil then
                -- require('telescope.previewers.utils').regex_highlighter(bufnr, 'json')
              end
            end,
          }
        )
      end,
    },
    attach_mappings = M.attach_mappings,
  }):find()
end

-- M.flake_picker()

return M
