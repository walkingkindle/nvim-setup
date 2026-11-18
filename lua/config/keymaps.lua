-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Methods in the current file (replaces LazyVim's <leader>sm "Marks")
vim.keymap.set("n", "<leader>sm", function()
  Snacks.picker.lsp_symbols({ filter = { default = { "Method" } } })
end, { desc = "Methods in File" })
