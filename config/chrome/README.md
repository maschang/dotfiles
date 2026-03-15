# Chrome Extensions 管理

`make chrome` で Chrome 拡張機能のインストール・更新を行う。

## Unpacked extensions（開発中・審査中）

`extensions.txt` に GitHub リポジトリ URL を1行ずつ記載する。

```
https://github.com/kyohei-masuda/my-extension-a
https://github.com/kyohei-masuda/my-extension-b
```

`make chrome` を実行すると `~/.chrome-extensions/` に clone/pull される。

初回のみ Chrome での手動登録が必要：

1. `chrome://extensions` を開く
2. 右上の「デベロッパーモード」を ON
3. 「パッケージ化されていない拡張機能を読み込む」→ `~/.chrome-extensions/<リポジトリ名>` を選択

更新時は `make chrome` 実行後、Chrome を再起動すれば反映される。

## Web Store extensions（審査通過後）

`extensions.json` に Extension ID を追加する。

```json
{
  "abcdefghijklmnop1234567890abcdef": {
    "external_update_url": "https://clients2.google.com/service/update2/crx"
  }
}
```

Extension ID は Chrome Web Store の URL またはデベロッパーダッシュボードから確認できる。

`make chrome` を実行すると `~/Library/Application Support/Google/Chrome/External Extensions/` に JSON が配置され、次回 Chrome 起動時にインストール確認ダイアログが表示される。

## 審査通過後の移行

1. `extensions.json` に Extension ID を追加
2. `extensions.txt` から該当リポジトリ URL を削除
3. `make chrome` を実行
