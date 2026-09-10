return {
  "glepnir/template.nvim",
  cmd = { "Template", "TemProject" },
  config = function()
    require("template").setup({
      -- stdpath resolves to ~/.config/nvim on Linux and %LOCALAPPDATA%\nvim on Windows
    temp_dir = vim.fn.stdpath("config") .. "/lua/templates",
      author = "Aleksa",
      email = "aleksa@business.com",
    })
  end,
}
