-- lazygit (<leader>gg): `o` on a file opens it as a buffer in this nvim instead of xdg-open.

-- Called by lazygit via --remote-expr: quit lazygit and focus the editor window behind its float,
-- so the following `--remote <file>` edits there instead of inside the closing float.
function LazygitLeave()
  if vim.bo.buftype == "terminal" then
    vim.api.nvim_chan_send(vim.bo.channel, "q")
  end
  vim.api.nvim_set_current_win(require("snacks.picker.core.main").new():get())
  return ""
end

return {
  "folke/snacks.nvim",
  opts = {
    lazygit = {
      config = {
        os = {
          open = 'nvim --server "$NVIM" --remote-expr "v:lua.LazygitLeave()" && nvim --server "$NVIM" --remote {{filename}}',
        },
      },
    },
  },
}
