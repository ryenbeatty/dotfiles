local map = vim.keymap.set

local function opts(desc)
  return { noremap = true, silent = true, desc = desc }
end

-- editing
map("i", "jk", "<ESC>", opts "escape insert")
map("n", ";", ":", opts "command mode")
map("v", "<", "<gv", opts "indent left")
map("v", ">", ">gv", opts "indent right")
map("n", "<ESC>", "<cmd>nohlsearch<cr>", opts "clear search highlight")

-- files / buffers
map("n", "<leader>w", "<cmd>write<cr>", opts "write buffer")
map("n", "<leader>q", "<cmd>quit<cr>", opts "quit window")
map("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", opts "toggle file tree")
map("n", "<S-l>", "<cmd>bnext<cr>", opts "next buffer")
map("n", "<S-h>", "<cmd>bprevious<cr>", opts "previous buffer")
map("n", "<leader>bd", "<cmd>bdelete<cr>", opts "delete buffer")

-- splits
map("n", "<C-h>", "<C-w>h", opts "window left")
map("n", "<C-j>", "<C-w>j", opts "window down")
map("n", "<C-k>", "<C-w>k", opts "window up")
map("n", "<C-l>", "<C-w>l", opts "window right")

-- diagnostics
map("n", "[d", function()
  vim.diagnostic.jump { count = -1 }
end, opts "previous diagnostic")
map("n", "]d", function()
  vim.diagnostic.jump { count = 1 }
end, opts "next diagnostic")
map("n", "<leader>dd", vim.diagnostic.open_float, opts "diagnostic float")
map("n", "<leader>dq", vim.diagnostic.setloclist, opts "diagnostics to loclist")

-- telescope
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", opts "find files")
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", opts "live grep")
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", opts "buffers")
map("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", opts "recent files")
map("n", "<leader>fd", "<cmd>Telescope diagnostics<cr>", opts "diagnostics")
map("n", "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", opts "document symbols")
map("n", "<leader>gs", "<cmd>Telescope git_status<cr>", opts "git status")

-- git (gitsigns)
map("n", "]h", "<cmd>Gitsigns next_hunk<cr>", opts "next hunk")
map("n", "[h", "<cmd>Gitsigns prev_hunk<cr>", opts "previous hunk")
map("n", "<leader>hp", "<cmd>Gitsigns preview_hunk<cr>", opts "preview hunk")
map("n", "<leader>hr", "<cmd>Gitsigns reset_hunk<cr>", opts "reset hunk")
map("n", "<leader>hb", "<cmd>Gitsigns blame_line<cr>", opts "blame line")

-- formatting
map("n", "<leader>f", function()
  require("conform").format { async = true, lsp_format = "fallback" }
end, opts "format buffer")
map("n", "<leader>uf", function()
  vim.b.disable_autoformat = not vim.b.disable_autoformat
  vim.notify("format on save: " .. (vim.b.disable_autoformat and "off" or "on"))
end, opts "toggle format on save")

-- LSP attach hooks live in lua/plugins/lsp.lua
