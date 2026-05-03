return {
  {
    "folke/tokyonight.nvim",
    lazy = true, -- Load on startup
    priority = 1000, -- Load before everything else
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
    config = function()
      -- Load the colorscheme here
      vim.cmd([[colorscheme tokyonight]])
    end,
  },
}
