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

## LSP

### 現在設定済みの LSP サーバー

| 言語 | サーバー名 | インストール方法 |
| --- | --- | --- |
| Ruby | `ruby_lsp` | `gem install ruby-lsp` |

### LSP の確認コマンド

| コマンド | 説明 |
| --- | --- |
| `:checkhealth lsp` | LSP 全体の状態確認 |
| `:LspInfo` | 現在のバッファにアタッチ中の LSP サーバーを表示 |
| `:LspLog` | LSP のログを確認（エラー調査時に便利） |

### 新しい言語の LSP を追加する手順

Mason は使っていないので、LSP サーバーは自分でインストールし、lspconfig で設定する。

#### 1. LSP サーバーをインストール

言語ごとのインストール例:

```bash
# TypeScript
npm install -g typescript-language-server typescript

# Go
go install golang.org/x/tools/gopls@latest

# Python
pip install python-lsp-server

# Lua
brew install lua-language-server
```

サーバー名は [nvim-lspconfig のドキュメント](https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md) で確認できる。

#### 2. `lua/plugins/init.lua` に設定を追加

`-- 他の LSP はここに追加` のコメント位置に以下の形式で追記:

```lua
-- TypeScript の例
vim.lsp.config("ts_ls", {})
vim.lsp.enable("ts_ls")
```

`vim.lsp.config()` の第2引数でサーバー固有の設定（`cmd`, `settings` 等）を渡せる:

```lua
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      diagnostics = { globals = { "vim" } },
    },
  },
})
vim.lsp.enable("lua_ls")
```

#### 3. 動作確認

1. nvim を再起動（または `:Lazy reload nvim-lspconfig`）
2. 対象言語のファイルを開く
3. `:LspInfo` でサーバーがアタッチされていることを確認
4. `K`（ホバー）や `gd`（定義ジャンプ）で動作テスト

### telescope.nvim のファイル検索バックエンド

`find_files` は以下の優先順でバックエンドを選択する。現環境では ripgrep が使われている。

| 優先順 | ツール | 状態 |
| --- | --- | --- |
| 1 | [fd](https://github.com/sharkdp/fd) | 未インストール（`brew install fd` で導入可） |
| 2 | [ripgrep](https://github.com/BurntSushi/ripgrep) (`rg --files`) | インストール済 |
| 3 | find | フォールバック |
