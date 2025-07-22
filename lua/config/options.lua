local opt = vim.opt

-- Leader Keys
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Performance
opt.updatetime = 200
opt.timeoutlen = 500

-- Integration
opt.mouse = "a"
vim.o.mousemoveevent = true
opt.clipboard = "unnamedplus"
opt.completeopt = { "menu", "menuone", "noselect" }

-- UI
opt.number = true
opt.relativenumber = false
opt.cursorline = true
opt.termguicolors = true
opt.signcolumn = "yes"
opt.scrolloff = 8
opt.whichwrap:append("<,>,h,l")
opt.wrap = false
opt.cmdheight = 1
opt.fillchars = { eob = " " }
opt.laststatus = 3
-- opt.list = true
-- opt.listchars = { tab = "→ ", trail = "·", space = "␣" }

-- Indentation
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true
opt.autoindent = true

-- Backtrack
opt.backup = false
opt.swapfile = false
opt.undofile = true

-- Searching
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Windows
opt.splitright = true
opt.splitbelow = true

opt.shortmess:append("I") -- no intro message
