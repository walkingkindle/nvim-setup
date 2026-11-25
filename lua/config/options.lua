-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.clipboard = "unnamedplus"

-- Open local text files in nvim (as a new buffer) instead of the system app (xdg-open).
-- Affects explorer `o` and `gx`; URLs, directories and binary files still use the system app.
local system_open = vim.ui.open
vim.ui.open = function(path, opt)
  local file = vim.fn.fnamemodify(path, ":p")
  local f = vim.fn.isdirectory(file) == 0 and io.open(file, "rb")
  if not f then
    return system_open(path, opt)
  end
  local is_binary = (f:read(8000) or ""):find("\0") ~= nil
  f:close()
  if is_binary then
    return system_open(path, opt)
  end
  -- edit in the main editor window, not inside the explorer sidebar
  vim.api.nvim_set_current_win(require("snacks.picker.core.main").new():get())
  vim.cmd.edit(vim.fn.fnameescape(file))
  return nil, nil
end
