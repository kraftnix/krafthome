require("remember_me").setup({
  ignore_ft = { "man", "gitignore", "gitcommit" },
  session_store = "~/.cache/remember-me/",
  project_roots = { ".git", ".svn" },
})
