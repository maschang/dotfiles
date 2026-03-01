local map = vim.keymap.set

-- 検索ハイライト解除
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- ウィンドウ移動
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- バッファ切り替え
map("n", "<Left>", "<cmd>bprevious<CR>")
map("n", "<Right>", "<cmd>bnext<CR>")

-- Telescope: キーマップは plugins/init.lua の keys で定義

-- Oil
map("n", "-", "<cmd>Oil<CR>")

-- LSP (lspconfig の on_attach で設定)
-- gd, gr, K 等は lua/plugins/init.lua 内で定義
