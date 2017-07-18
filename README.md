# dotfiles

## セットアップ

```sh
git clone https://github.com/maschang/dotfiles.git ~/devel/dotfiles
cd ~/devel/dotfiles
make install
```

`make install` は `make brew` + `make link` を実行する。

## ディレクトリ構成

```
dotfiles/
├── Makefile                 # make install / make link / make brew
├── Brewfile                 # brew bundle 用
├── home/                    # ~/ 直下に ~/.{name} としてリンク
│   ├── zshrc                #   → ~/.zshrc
│   ├── gitconfig            #   → ~/.gitconfig
│   ├── gitignore            #   → ~/.gitignore
│   └── claude/              #   → ~/.claude
│       ├── settings.json
│       ├── CLAUDE.md
│       ├── agents/
│       └── skills/
├── config/                  # ~/ 直下以外の特殊パスにリンク
│   ├── cursor/              #   → ~/Library/Application Support/Cursor/User/
│   │   ├── settings.json
│   │   └── keybindings.json
│   └── iterm2/              #   make iterm2 でインポート
│       └── TokyoNight.itermcolors
└── scripts/
    ├── link.sh              # シンボリックリンク作成
    └── brew.sh              # Homebrew インストール
```

## コマンド一覧

```sh
make help     # ターゲット一覧
make install  # brew + link を実行
make brew     # Homebrew インストール & brew bundle
make link     # シンボリックリンク作成
make iterm2   # iTerm2 にカラースキームをインポート
```

## 設定を追加・変更したいとき

### brew パッケージを追加したい

`Brewfile` に追記する。

```ruby
brew "ripgrep"       # CLI ツール
cask "visual-studio-code"  # GUI アプリ
```

追記後 `make brew` で反映。

### dotfile を追加したい

`home/` にファイルやディレクトリを置く。`make link` で自動的に `~/.{name}` にシンボリックリンクされる（`scripts/link.sh` の変更不要）。

例: `home/tmux.conf` → `~/.tmux.conf`、`home/claude/` → `~/.claude`

### config/ 以下のツール設定を追加したい

`config/` はツールごとのリンク先が異なるため、`scripts/link.sh` への追記が必要。

| リンク先のパス | 方針 | 例 |
|---|---|---|
| `~/.config/{name}/` | XDG 対応ツール。`link.sh` で `~/.config/` にリンク | wezterm, nvim |
| `~/Library/...` 等 | macOS アプリ。ツール固有のパスにリンク | Cursor |
| リンク不可 | `open` やコマンドでインポート | iTerm2 (.itermcolors) |

### zsh の alias や関数を追加したい

`home/zshrc` を直接編集する。

### Claude Code

`make link` で `home/claude/` → `~/.claude` にシンボリックリンクされる。
設定ファイル（`settings.json`）、ユーザー CLAUDE.md、カスタムエージェント、スキルが同期される。

- `~/.claude.json`（OAuth トークン等）は dotfiles 管理外。各端末で `claude auth login` が必要。
- `~/.claude/projects/` 以下のプロジェクト固有設定はシンボリックリンク先に書き込まれるので、必要なものは commit する。
