return {
  "nvim-treesitter/nvim-treesitter",
  -- master is the pre-rewrite branch: it still ships require("nvim-treesitter.configs"),
  -- which this config uses. Pinning it means :TSUpdate cannot silently jump to the
  -- rewritten main branch and break highlighting.
  branch = "master",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    require("nvim-treesitter.configs").setup {
      ensure_installed = {
        "lua",
        "vim",
        "vimdoc",
        "typescript",
        "tsx",
        "javascript",
        "html",
        "css",
        "json",
        "yaml",
        "markdown",
        "markdown_inline",
        "bash",
      },
      auto_install = false,
      highlight = { enable = true },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          node_decremental = "<C-s>",
        },
      },
    }
  end,
}
