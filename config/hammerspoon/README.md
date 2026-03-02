# Hammerspoon 設定

## セットアップ

```bash
brew install --cask hammerspoon
make link
```

初回起動時に「アクセシビリティ」の権限許可が必要。
System Settings > Privacy & Security > Accessibility で Hammerspoon を許可する。

## キーバインド

| キー | 機能 |
|---|---|
| `opt + t` | WezTerm にフォーカス（未起動なら起動） |
| `opt + c` | Google Chrome にフォーカス |
| `opt + s` | Slack にフォーカス |
| `opt + l` | `localhost:3000` をブラウザで開く |
| `opt + space` | アプリ検索ランチャー |

## ファイル構成

| ファイル | 内容 |
|---|---|
| `init.lua` | エントリポイント。設定の自動リロード付き |
| `window_switcher.lua` | アプリ切り替えのキーバインド |
| `open_localhost.lua` | localhost を開くキーバインド |
| `app_search.lua` | アプリ検索ランチャー |

## カスタマイズ

### ポート番号の変更

`open_localhost.lua` の `port` 変数を変更する。

```lua
local port = 3010
```

### アプリ切り替え対象の追加

`window_switcher.lua` の `apps` テーブルに追加する。

```lua
{ key = "f", app = "Finder" },
```
