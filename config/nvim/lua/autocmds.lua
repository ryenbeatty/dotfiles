-- brief highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "highlight yanked text",
  group = vim.api.nvim_create_augroup("dotfiles-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank { timeout = 120 }
  end,
})

-- reload files changed on disk (e.g. by git checkout)
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  desc = "check for external changes",
  group = vim.api.nvim_create_augroup("dotfiles-checktime", { clear = true }),
  command = "checktime",
})
