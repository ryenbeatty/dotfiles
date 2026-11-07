return {
  -- file tree (kept from the previous setup)
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "NvimTreeToggle", "NvimTreeFocus", "NvimTreeFindFile" },
    opts = {
      view = { width = 34, side = "left" },
      renderer = { group_empty = true, highlight_git = true },
      filters = { dotfiles = false },
      git = { enable = true, ignore = false },
      update_focused_file = { enable = true },
    },
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        { "<leader>f", group = "find / format" },
        { "<leader>g", group = "git" },
        { "<leader>d", group = "diagnostics" },
        { "<leader>h", group = "hunks" },
        { "<leader>r", group = "rename / refactor" },
        { "<leader>c", group = "code" },
        { "<leader>b", group = "buffer" },
      },
    },
  },

  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    opts = {
      options = {
        theme = "gruvbox",
        globalstatus = true,
        section_separators = "",
        component_separators = "|",
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff" },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "diagnostics", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
  },

  {
    "echasnovski/mini.nvim",
    version = false,
    event = { "BufReadPre", "BufNewFile", "InsertEnter" },
    config = function()
      require("mini.pairs").setup {}
      require("mini.surround").setup {}
      require("mini.comment").setup {}
      require("mini.ai").setup {}
    end,
  },
}
