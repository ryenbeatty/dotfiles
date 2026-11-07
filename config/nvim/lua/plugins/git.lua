return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    signs = {
      add = { text = "│" },
      change = { text = "│" },
      delete = { text = "_" },
      topdelete = { text = "‾" },
      changedelete = { text = "~" },
    },
    current_line_blame = false,
    on_attach = function(buffer)
      local gs = package.loaded.gitsigns
      local map = vim.keymap.set
      local function buf(desc, lhs, rhs)
        map("n", lhs, rhs, { buffer = buffer, desc = desc })
      end
      buf("stage hunk", "<leader>hs", gs.stage_hunk)
      buf("reset hunk", "<leader>hr", gs.reset_hunk)
      buf("stage buffer", "<leader>hS", gs.stage_buffer)
      buf("toggle deleted", "<leader>hd", gs.toggle_deleted)
      buf("toggle blame line", "<leader>hb", function()
        gs.toggle_current_line_blame()
      end)
    end,
  },
}
