local opt = vim.opt

-- 行番号
opt.number = true
opt.relativenumber = true

-- インデント
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true

-- 検索
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true

-- 表示
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.scrolloff = 8

-- ファイル
opt.swapfile = false
opt.undofile = true

-- 分割
opt.splitbelow = true
opt.splitright = true

-- クリップボード
opt.clipboard = "unnamedplus"
