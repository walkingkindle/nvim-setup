-- bootstrap lazy.nvim, LazyVim and your plugins
vim.g.mapleader = " "
require("config.lazy")

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
vim.keymap.set("n", "<leader>q", "<cmd>Neotree toggle<CR>", { desc = "Toggle Neo-tree", noremap = true, silent = true })
vim.keymap.set("n", "<leader>e", "<cmd>Neotree reveal<CR>", { desc = "Focus Neo-tree" })
vim.keymap.set(
  "n",
  "<leader>t",
  ":botright split | term<CR>a",
  { desc = "Open terminal at bottom", noremap = true, silent = true }
)
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show full error message" })
vim.keymap.set("n", "<leader>]]", ":DotnetUI project package add", { desc = "Add package to dotnet" })
vim.keymap.set("n", "<C-/>", "gcc", { remap = true, desc = "Toggle comment" })
vim.keymap.set("v", "<C-/>", "gc", { remap = true, desc = "Toggle comment" })
vim.keymap.set("n", "<leader>r", "<cmd>GrugFar<cr>", { desc = "Search and Replace" })
vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], { noremap = true })

vim.keymap.set("n", "<leader>sR", function()
  local grug = require("grug-far")
  local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
  grug.open({
    transient = true,
    prefills = {
      filesFilter = ext and ext ~= "" and "*." .. ext or nil,
    },
  })
end, { desc = "[s]earch [R]eplace (grug-far)" })

require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    cs = { "csharpier" },
    typescript = { "prettier" },
    typescriptreact = { "prettier" },
    markdown = { "prettier" },
    html = { "prettier" },
    css = { "prettier" },
    xml = { "xmlformat" },
    go = { "gofumpt" },
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

    if filename:match("^I%u") then
      table.insert(result, "namespace " .. ns .. ";")
      table.insert(result, "")
      table.insert(result, "public interface " .. filename)
      table.insert(result, "{")
      table.insert(result, "    ")
      table.insert(result, "}")
    elseif name_lower:find("controller") then
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

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
function Transparent(color)
  color = color or "tokyonight"
  vim.cmd.colorscheme(color)
  local groups = {
    "Normal",
    "NormalFloat",
    "NormalNC",
    "SignColumn",
    "EndOfBuffer",
    "Terminal",
  }

  for _, group in ipairs(groups) do
    vim.api.nvim_set_hl(0, group, { bg = "none" })
  end
end

-- Transparent()
