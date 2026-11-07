local opt = vim.opt

-- editing
opt.expandtab = true
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.autoindent = true
opt.smartindent = true

-- line numbers / columns
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false

-- files
opt.undofile = true
opt.swapfile = false
opt.backup = false
opt.updatetime = 250

-- search
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = false

-- windows
opt.splitright = true
opt.splitbelow = true
opt.laststatus = 3
opt.timeoutlen = 400

-- appearance
opt.termguicolors = true
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- system integration
opt.clipboard = "unnamedplus"
opt.mouse = "a"
