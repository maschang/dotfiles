# ~/.claude の管理ファイル

`make link` で `~/.claude` にシンボリックリンクされる。
Claude Code の仕様変更が多いため、各ファイルの役割をここにまとめておく。

## ファイル一覧

| ファイル | 役割 | 公式ドキュメント |
|---|---|---|
| `settings.json` | user-scope の設定。permissions（allow/deny）、環境変数など | [Settings](https://docs.anthropic.com/en/docs/claude-code/settings) |
| `CLAUDE.md` | 全プロジェクト共通のユーザーメモリ。作業フロー・個人的な指示を記述 | [Memory](https://docs.anthropic.com/en/docs/claude-code/memory) |
| `agents/*.md` | カスタムサブエージェント定義。YAML frontmatter + 本文 | [Sub-agents](https://docs.anthropic.com/en/docs/claude-code/sub-agents) |
| `skills/*/SKILL.md` | カスタムスキル定義。`/skill-name` で手動実行もできる | [Skills](https://docs.anthropic.com/en/docs/claude-code/skills) |
| `rules/*.md` | トピック別・パス別のモジュラールール。CLAUDE.md を分割したいときに使う | [Memory](https://docs.anthropic.com/en/docs/claude-code/memory) |

## agents と skills の使い分け

| | agents | skills |
|---|---|---|
| 実体 | 独立したサブエージェント（別コンテキストで動く） | メインの Claude に注入されるプロンプト |
| コンテキスト | 親の会話を引き継がない | 今の会話の文脈をそのまま使える |
| 起動 | Claude が自動起動 or ユーザー指定 | `/skill-name` で手動、または Claude が自動判断 |
| 向いている用途 | 重い自律タスク（探索、テスト実行、ビルド等） | 手順・フォーマットの定型化（レビュー、PR作成等） |

**判断基準: 「今の会話の文脈が必要か？」**
- 必要 → skill（会話の流れを踏まえて動ける）
- 不要で独立して動かしたい → agent

## CLAUDE.md と rules/ の使い分け

- **CLAUDE.md** — 全体方針、作業フロー。常にすべてのファイルに適用される
- **rules/*.md** — トピック別に分割したルール。YAML frontmatter の `paths:` で特定ファイルにだけ適用できる

```markdown
# rules/typescript.md の例
---
paths:
  - "src/**/*.ts"
  - "src/**/*.tsx"
---
- strict モードを使う
- any を避ける
```

CLAUDE.md が肥大化してきたら rules/ に切り出す、くらいの運用でよい。最初から分割する必要はない。

## dotfiles で管理しないもの

| パス | 理由 |
|---|---|
| `~/.claude.json` | OAuth トークン等の秘匿情報を含む |
| `~/.claude/projects/` | プロジェクト固有の設定・メモリ。シンボリックリンク先に自動生成される |

## 仕様が変わったら

1. 上の公式ドキュメントのリンクを確認する
2. 不要になったファイルは削除、新しいファイルが必要ならここに追記する
3. `settings.json` の permission 記法が変わりやすいので特に注意
