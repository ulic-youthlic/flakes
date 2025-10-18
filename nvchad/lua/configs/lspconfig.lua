require("nvchad.configs.lspconfig").defaults()

local servers = {
  "rust_analyzer",
  "nixd",
  "nil_ls",
  "lua_ls",
  "jsonls",
  "taplo"
}
vim.lsp.enable(servers, true)

local lua_ls_libraries = vim.deepcopy(vim.lsp.config.lua_ls.settings.Lua.workspace.library)
table.insert(lua_ls_libraries,
  #lua_ls_libraries, vim.fn.stdpath "data" .. "/lazy/NvChad/lua/nvchad")
vim.lsp.config.lua_ls.settings.Lua.workspace.library = lua_ls_libraries
