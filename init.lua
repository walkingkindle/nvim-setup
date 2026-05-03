-- bootstrap lazy.nvim, LazyVim and your plugins
vim.g.mapleader = " "
require("config.lazy")

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
vim.keymap.set("n", "<leader>q", "<cmd>Neotree toggle<CR>", { desc = "Toggle Neo-tree", noremap = true, silent = true })
vim.keymap.set("n", "<leader>t", ":terminal", { desc = "Open Terminal", noremap = true, silent = true })
vim.keymap.set("n", "<leader>e", "<cmd>Neotree focus<CR>", { desc = "Focus Neo-tree" })
vim.keymap.set(
  "n",
  "<leader>t",
  ":botright split | term<CR>a",
  { desc = "Open terminal at bottom", noremap = true, silent = true }
)
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show full error message" })
vim.keymap.set("n", "<leader>]]", ":DotnetUI project package add", { desc = "Add package to dotnet" })

require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    cs = { "csharpier" }, -- 'cs' is the filetype for C#
  },
})
vim.keymap.set("n", "<leader>/", function()
  require("conform").format({
    lsp_fallback = true,
    async = false,
    timeout_ms = 500,
  })
end, { desc = "Format file" })

vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPost" }, {
  pattern = "*.cs",
  callback = function(args)
    local lines = vim.api.nvim_buf_get_lines(args.buf, 0, -1, false)
    local is_empty = #lines == 0 or (#lines == 1 and lines[1] == "")
    if not is_empty then
      return
    end

    local filename = vim.fn.expand("%:t:r")
    local name_lower = filename:lower()

    -- build namespace from relative path
    local rel_dir = vim.fn.expand("%:.:h")
    local ns
    if rel_dir == "" or rel_dir == "." then
      ns = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
    else
      ns = rel_dir:gsub("[/\\]", ".")
    end

    local result = {}

    if name_lower:find("controller") then
      table.insert(result, "using Microsoft.AspNetCore.Mvc;")
      table.insert(result, "")
      table.insert(result, "namespace " .. ns .. ";")
      table.insert(result, "")
      table.insert(result, "[ApiController]")
      table.insert(result, '[Route("[controller]")]')
      table.insert(result, "public class " .. filename .. " : ControllerBase")
      table.insert(result, "{")
      table.insert(result, "    ")
      table.insert(result, "}")
    elseif name_lower:find("test") then
      table.insert(result, "using Xunit;")
      table.insert(result, "")
      table.insert(result, "namespace " .. ns .. ";")
      table.insert(result, "")
      table.insert(result, "public class " .. filename)
      table.insert(result, "{")
      table.insert(result, "    [Fact]")
      table.insert(result, "    public void Test1()")
      table.insert(result, "    {")
      table.insert(result, "        ")
      table.insert(result, "    }")
      table.insert(result, "}")
    else
      table.insert(result, "namespace " .. ns .. ";")
      table.insert(result, "")
      table.insert(result, "public class " .. filename)
      table.insert(result, "{")
      table.insert(result, "    ")
      table.insert(result, "}")
    end

    vim.api.nvim_buf_set_lines(args.buf, 0, -1, false, result)
  end,
})

function Transparent(color)
  color = color or "tokyonight"
  vim.cmd.colorscheme(color)
  vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end
Transparent()
