require "nvchad.mappings"

local map = vim.keymap.set

map("n", "<M-x>", ":", { desc = "CMD enter command mode" })
map("n", "<leader>ti", function()
  local is_enabled = vim.lsp.inlay_hint.is_enabled()
  if is_enabled then
    vim.lsp.inlay_hint.enable(false)
  else
    vim.lsp.inlay_hint.enable(true)
  end
end, { desc = "Toggle lsp inlay hint" })

map({ "n", "v" }, "j", "gj")
map({ "n", "v" }, "k", "gk")
map({ "n", "v" }, "gj", "j")
map({ "n", "v" }, "gk", "k")
map({ "n", "v" }, "<C-h>", "<cmd>Telescope help_tags<CR>", { desc = "telescope help page" })
map("i", "<C-d>", "<BS>", { desc = "backspace" })
map({ "n", "v" }, "<leader>tm", function()
  local image_api = require("image")
  local is_enabled = image_api.is_enabled()
  if is_enabled then
    image_api.disable()
  else
    image_api.enable()
  end
end, { desc = "Toggle image.nvim" })
