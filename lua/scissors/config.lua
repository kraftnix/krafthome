local M = {}
--------------------------------------------------------------------------------

---@class (exact) pluginConfig
---@field snippetDir string
---@field editSnippetPopup { height: number, width: number, border: string, keymaps: popupKeymaps }
---@field backdrop { enabled: boolean, blend: number }
---@field telescope telescopeConfig
---@field jsonFormatter "yq"|"jq"|"none"

---@class (exact) popupKeymaps
---@field cancel string
---@field saveChanges string
---@field deleteSnippet string
---@field duplicateSnippet string
---@field openInFile string
---@field insertNextToken string
---@field goBackToSearch string
---@field jumpBetweenBodyAndPrefix string

---@class (exact) telescopeConfig
---@field alsoSearchSnippetBody boolean

---@type pluginConfig
local defaultConfig = {
	snippetDir = vim.fn.stdpath("config") .. "/snippets",
	editSnippetPopup = {
		height = 0.4, -- relative to the window, between 0-1
		width = 0.6,
		border = "rounded",
		keymaps = {
			cancel = "q",
			saveChanges = "<CR>", -- alternatively, can also use `:w`
			goBackToSearch = "<BS>",
			deleteSnippet = "<C-BS>",
			duplicateSnippet = "<C-d>",
			openInFile = "<C-o>",
			insertNextToken = "<C-t>", -- insert & normal mode
			jumpBetweenBodyAndPrefix = "<C-Tab>", -- insert & normal mode
		},
	},
	backdrop = {
		enabled = true,
		blend = 50, -- between 0-100
	},
	telescope = {
		-- By default, the query only searches snippet prefixes. Set this to
		-- `true` to also search the body of the snippets.
		alsoSearchSnippetBody = false,
	},
	-- `none` writes as a minified json file using `:h vim.encode.json`.
	-- `yq` and `jq` ensure formatted & sorted json files, which is relevant when
	-- you are version control your snippets.
	jsonFormatter = "none", -- "yq"|"jq"|"none"
}

--------------------------------------------------------------------------------

M.config = defaultConfig -- in case user does not call `setup`

---@param userConfig? pluginConfig
function M.setupPlugin(userConfig)
	M.config = vim.tbl_deep_extend("force", defaultConfig, userConfig or {})

	-- normalizing e.g. expands `~` in provided snippetDir
	M.config.snippetDir = vim.fs.normalize(M.config.snippetDir)

	-- VALIDATE border `none` does not work with and title/footer used by this plugin
	if M.config.editSnippetPopup.border == "none" then
		local fallback = defaultConfig.editSnippetPopup.border
		M.config.editSnippetPopup.border = fallback
		local msg = ('Border type "none" is not supported, falling back to %q'):format(fallback)
		require("scissors.utils").notify(msg, "warn")
	end
end

--------------------------------------------------------------------------------
return M
