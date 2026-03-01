# Neovim プラグイン一覧

## プラグインマネージャ

| プラグイン | 説明 |
| --- | --- |
| [lazy.nvim](https://github.com/folke/lazy.nvim) | プラグインマネージャ。遅延読み込み対応で起動が速い |

## プラグイン

| プラグイン | 説明 |
| --- | --- |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | 構文解析ベースのシンタックスハイライト。正確な色分けとインデントを提供 |
| [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) | ファジーファインダー。ファイル検索・全文検索・バッファ切替などを統一 UI で操作 |
| [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) | Telescope の必須依存ライブラリ。Lua ユーティリティ集 |
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | LSP クライアント設定。定義ジャンプ・参照検索・ホバーなどの IDE 機能を提供 |
| [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | Git 差分をサインカラム（行番号横）にリアルタイム表示 |
| [oil.nvim](https://github.com/stevearc/oil.nvim) | ファイルシステムを通常バッファのように操作できるファイルエクスプローラ。`-` で開く |

## 外部依存ツール

| ツール | 用途 |
| --- | --- |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | Telescope の `live_grep`（全文検索）で使用 |
| [ruby-lsp](https://github.com/Shopify/ruby-lsp) | Ruby 用 LSP サーバー。nvim-lspconfig から自動接続 |
