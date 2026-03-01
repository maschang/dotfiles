local map = vim.keymap.set

-- 検索ハイライト解除
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- ウィンドウ移動
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- Telescope
map("n", "<leader>ff", "<cmd>Telescope find_files<CR>")
map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>")
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>")
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>")

-- Oil
map("n", "-", "<cmd>Oil<CR>")

-- LSP (lspconfig の on_attach で設定)
-- gd, gr, K 等は lua/plugins/init.lua 内で定義
