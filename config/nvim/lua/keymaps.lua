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

-- ファイルパスをクリップボードにコピー
map("n", "<leader>cp", function()
  vim.fn.setreg("+", vim.fn.expand("%:."))
  vim.notify("Copied: " .. vim.fn.expand("%:."))
end, { desc = "Copy relative file path" })
map("n", "<leader>cP", function()
  vim.fn.setreg("+", vim.fn.expand("%:p"))
  vim.notify("Copied: " .. vim.fn.expand("%:p"))
end, { desc = "Copy absolute file path" })

-- LSP (lspconfig の on_attach で設定)
-- gd, gr, K 等は lua/plugins/init.lua 内で定義

-- :q でバッファが残っていれば閉じて前のバッファを表示、なければ終了
vim.api.nvim_create_user_command("Q", function(opts)
  local bufs = vim.fn.getbufinfo({ buflisted = 1 })
  local bang = opts.bang and "!" or ""
  if #bufs > 1 then
    vim.cmd("bprevious | bdelete" .. bang .. " #")
  else
    vim.cmd("quit" .. bang)
  end
end, { bang = true })
vim.cmd("cabbrev q Q")
