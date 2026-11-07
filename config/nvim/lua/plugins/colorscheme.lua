return {
  "ellisonleao/gruvbox.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    -- alacritty runs at opacity 0.8, so let the background through
    transparent = true,
    contrast = "hard",
    italic = { strings = false, comments = true, folds = false, emphasis = true },
  },
  config = function(_, opts)
    require("gruvbox").setup(opts)
    vim.o.background = "dark"
    vim.cmd.colorscheme "gruvbox"
  end,
}
