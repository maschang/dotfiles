---
name: skill-creator
description: スキルの新規作成、既存スキルの改善、スキル性能の測定を行う。スキルをゼロから作りたい、既存スキルを編集・最適化したい、eval でスキルをテストしたい、ベンチマークで性能を比較したい、description を最適化してトリガー精度を上げたい、といった場面で使用する。「スキルを作って」「このワークフローをスキル化して」「スキルの eval を回したい」「description を改善したい」などのリクエストにも積極的に反応すること。
---

# Skill Creator

スキルの新規作成と反復的な改善を行うためのスキル。

## 全体の流れ

1. スキルの目的と方針を決める
2. スキルのドラフトを書く
3. テストプロンプトを作成し、スキル付きの Claude で実行する
4. 結果を定性・定量の両面で評価する
   - 実行中に定量 eval（assertion）を作成する（既存のものがあればそれを確認・説明）
   - `eval-viewer/generate_review.py` で結果を表示し、ユーザーに確認してもらう
5. フィードバックに基づいてスキルを改善する
6. 満足するまで繰り返す
7. テストセットを拡大し、より大規模に検証する

ユーザーがこのプロセスのどの段階にいるかを判断し、適切な地点から支援を始める。既にドラフトがあれば eval/改善ループから開始する。ユーザーが「eval は不要、一緒に作りながら進めたい」と言えばそれに合わせる。

スキル完成後、description の最適化も提案できる（専用スクリプトあり）。

## ユーザーとのコミュニケーション

ユーザーの技術レベルに合わせて説明の粒度を調整する。

- 「eval」「ベンチマーク」はそのまま使ってよい
- 「JSON」「assertion」などの用語は、ユーザーが理解していそうなら説明なしで使い、不明なら簡潔に補足する

---

## スキルの作成

### 意図の把握

ユーザーの意図を理解することから始める。会話の中に既にワークフローが含まれている場合（例：「これをスキルにして」）、まず会話履歴から情報を抽出する — 使ったツール、手順、ユーザーの修正、入出力形式など。不足があればユーザーに確認し、次のステップに進む前に合意を得る。

1. このスキルで Claude に何をさせたいか？
2. どのような状況・フレーズでトリガーすべきか？
3. 期待する出力形式は？
4. テストケースを用意するか？ — 客観的に検証可能な出力（ファイル変換、データ抽出、コード生成、定型ワークフロー）にはテストケースが有効。主観的な出力（文体、デザイン）には不要なことが多い。スキルの性質に応じてデフォルトを提案し、ユーザーに判断を委ねる。

### ヒアリングとリサーチ

エッジケース、入出力形式、サンプルファイル、成功基準、依存関係について積極的に質問する。テストプロンプトの作成はこのステップの完了後に行う。

利用可能な MCP があれば、リサーチに活用する（ドキュメント検索、類似スキルの調査、ベストプラクティスの確認など）。サブエージェントが使えれば並列で、なければインラインで実施する。

### SKILL.md の作成

ヒアリング結果を基に、以下の要素を記述する：

- **name**: スキル識別子
- **description**: トリガー条件と機能の説明。スキルのトリガーを決定する最も重要なフィールド。スキルの機能と「いつ使うべきか」の両方を具体的に記述する。「いつ使うか」の情報はすべてここに集約し、本文には書かない。Claude はスキルを「使わなすぎる」傾向があるため、description はやや積極的に書く。例：「社内データのダッシュボードを構築する方法」→「社内データのダッシュボードを構築する方法。ダッシュボード、データ可視化、社内メトリクス、データ表示に関するリクエストがあれば、ユーザーが明示的に『ダッシュボード』と言わなくてもこのスキルを使用すること。」
- **compatibility**: 必要なツール・依存関係（任意、ほとんど不要）
- **本文**: スキルの指示内容

### スキル設計ガイド

#### スキルの構成

```
skill-name/
├── SKILL.md (required)
│   ├── YAML frontmatter (name, description required)
│   └── Markdown instructions
└── Bundled Resources (optional)
    ├── scripts/    - Executable code for deterministic/repetitive tasks
    ├── references/ - Docs loaded into context as needed
    └── assets/     - Files used in output (templates, icons, fonts)
```

#### Progressive Disclosure

スキルは3段階でロードされる：
1. **メタデータ**（name + description）— 常にコンテキストに存在（目安100語）
2. **SKILL.md 本文** — スキル発火時にロード（500行以下が理想）
3. **バンドルリソース** — 必要に応じてロード（制限なし。スクリプトはロードなしで実行可能）

語数は目安であり、必要なら超えてもよい。

**設計パターン：**
- SKILL.md は500行以下に保つ。上限に近づいたら階層を追加し、次に読むべきファイルへのポインターを明示する
- SKILL.md からリファレンスファイルを明確に参照し、いつ読むべきかのガイダンスを付ける
- 大きなリファレンスファイル（300行超）には目次を付ける

**ドメイン別整理**: 複数のドメインやフレームワークに対応するスキルは、バリアントごとに整理する：
```
cloud-deploy/
├── SKILL.md (workflow + selection)
└── references/
    ├── aws.md
    ├── gcp.md
    └── azure.md
```
Claude は関連するリファレンスファイルだけを読む。

#### 安全性の原則

スキルにマルウェア、エクスプロイトコード、セキュリティを侵害するコンテンツを含めてはならない。スキルの内容は、説明された場合にユーザーが驚かないものであること。不正アクセスやデータ流出を目的とするスキルの作成には応じない。ロールプレイ系のスキルは問題ない。

#### 記述パターン

指示は命令形で書く。

**出力形式の定義例：**
```markdown
## Report structure
ALWAYS use this exact template:
# [Title]
## Executive summary
## Key findings
## Recommendations
```

**サンプルの記述例：**
```markdown
## Commit message format
**Example 1:**
Input: Added user authentication with JWT tokens
Output: feat(auth): implement JWT-based authentication
```

### 記述スタイル

ALWAYS / NEVER を多用するのではなく、「なぜそうすべきか」を説明する。LLM は理由を理解すれば、硬直的な命令がなくても適切に動作する。スキルを汎用的にし、特定の例に過度に特化させない。ドラフトを書いたら一度離れて見直し、改善する。

### テストケース

スキルのドラフト完成後、2〜3 の現実的なテストプロンプトを作成する。実際のユーザーが言いそうな内容にする。ユーザーに提示して確認を取り、実行する。

テストケースは `evals/evals.json` に保存する。この段階では assertion は書かず、プロンプトのみ。assertion は次のステップで実行中に作成する。

```json
{
  "skill_name": "example-skill",
  "evals": [
    {
      "id": 1,
      "prompt": "User's task prompt",
      "expected_output": "Description of expected result",
      "files": []
    }
  ]
}
```

完全なスキーマは `references/schemas.md` を参照（`assertions` フィールドは後で追加）。

## テストケースの実行と評価

このセクションは一連の流れとして最後まで実行する。途中で止めない。`/skill-test` などの他のテスト用スキルは使用しない。

結果は `<skill-name>-workspace/` にスキルディレクトリの兄弟として配置する。ワークスペース内はイテレーションごと（`iteration-1/`, `iteration-2/`）に整理し、各テストケースにディレクトリを作る（`eval-0/`, `eval-1/` など）。事前に全体を作らず、進行に応じて作成する。

### Step 1: 全実行を同一ターンで起動する（with-skill と baseline の両方）

各テストケースについて、同一ターンで2つのサブエージェントを起動する — スキルありとスキルなし。スキルありだけ先に実行してから baseline を後回しにしない。全てを一度に起動し、同時に完了させる。

**スキルあり実行：**

```
Execute this task:
- Skill path: <path-to-skill>
- Task: <eval prompt>
- Input files: <eval files if any, or "none">
- Save outputs to: <workspace>/iteration-<N>/eval-<ID>/with_skill/outputs/
- Outputs to save: <what the user cares about — e.g., "the .docx file", "the final CSV">
```

**Baseline 実行**（同じプロンプト、ただし baseline の内容は状況による）：
- **新規スキル作成時**: スキルなしで実行。同じプロンプト、スキルパスなし、`without_skill/outputs/` に保存。
- **既存スキル改善時**: 旧バージョンを使用。編集前にスキルをスナップショット（`cp -r <skill-path> <workspace>/skill-snapshot/`）し、baseline サブエージェントはそのスナップショットを参照。`old_skill/outputs/` に保存。

各テストケースに `eval_metadata.json` を作成する（assertion は空でよい）。eval にはテスト内容を表す説明的な名前を付ける（"eval-0" のような機械的な名前は避ける）。ディレクトリ名にもこの名前を使う。新しいイテレーションで eval プロンプトが変わった場合は、各 eval ディレクトリに新しくファイルを作成する（前回から引き継がれるとは仮定しない）。

```json
{
  "eval_id": 0,
  "eval_name": "descriptive-name-here",
  "prompt": "The user's task prompt",
  "assertions": []
}
```

### Step 2: 実行中に assertion を作成する

実行完了を待つ間に、各テストケースの定量的 assertion を作成し、ユーザーに説明する。既存の assertion が `evals/evals.json` にあれば、内容を確認して説明する。

良い assertion は客観的に検証可能で、説明的な名前を持つ。ベンチマークビューアーで一目で何を確認しているかわかるようにする。主観的なスキル（文体、デザイン品質）は定性評価が適しており、assertion を無理に作らない。

`eval_metadata.json` と `evals/evals.json` を assertion で更新する。ビューアーで何が表示されるか（定性的な出力と定量的ベンチマーク）もユーザーに説明する。

### Step 3: 実行完了時にタイミングデータを記録する

サブエージェントタスク完了時の通知に `total_tokens` と `duration_ms` が含まれる。このデータは通知でしか取得できないため、届き次第 `timing.json` に保存する：

```json
{
  "total_tokens": 84852,
  "duration_ms": 23332,
  "total_duration_seconds": 23.3
}
```

通知ごとに即座に処理し、バッチ処理しない。

### Step 4: 採点、集計、ビューアー起動

全実行完了後：

1. **採点** — grader サブエージェントを起動（またはインラインで採点）し、`agents/grader.md` を読んで各 assertion を出力に対して評価する。結果を各実行ディレクトリの `grading.json` に保存する。grading.json の expectations 配列は `text`, `passed`, `evidence` フィールドを使用すること（`name`/`met`/`details` 等は不可）— ビューアーがこのフィールド名に依存している。プログラムで検証可能な assertion はスクリプトで検証する（目視より高速・高精度・再利用可能）。

2. **ベンチマーク集計** — skill-creator ディレクトリから集計スクリプトを実行する：
   ```bash
   python -m scripts.aggregate_benchmark <workspace>/iteration-N --skill-name <name>
   ```
   `benchmark.json` と `benchmark.md` が生成され、各構成の pass_rate、時間、トークン数が mean ± stddev と差分で表示される。benchmark.json を手動生成する場合は `references/schemas.md` のスキーマを参照すること。各 with_skill を対応する baseline の前に配置する。

3. **分析パス** — ベンチマークデータを読み、集計統計では見えないパターンを抽出する。`agents/analyzer.md` の "Analyzing Benchmark Results" セクションを参照 — 常に pass する assertion（弁別力なし）、高分散の eval（不安定の可能性）、時間/トークンのトレードオフなど。

4. **ビューアー起動** — 定性出力と定量データの両方を表示：
   ```bash
   nohup python <skill-creator-path>/eval-viewer/generate_review.py \
     <workspace>/iteration-N \
     --skill-name "my-skill" \
     --benchmark <workspace>/iteration-N/benchmark.json \
     > /dev/null 2>&1 &
   VIEWER_PID=$!
   ```
   iteration 2 以降は `--previous-workspace <workspace>/iteration-<N-1>` も指定する。

   **Cowork / ヘッドレス環境:** `webbrowser.open()` が使えない場合は `--static <output_path>` でスタンドアロン HTML を出力する。フィードバックは "Submit All Reviews" クリック時に `feedback.json` としてダウンロードされる。ダウンロード後、次のイテレーション用にワークスペースディレクトリにコピーする。

   ビューアーは generate_review.py で生成する。独自の HTML を書く必要はない。

5. **ユーザーへの案内** — 「ブラウザで結果を開きました。'Outputs' タブで各テストケースの結果を確認してフィードバックを記入でき、'Benchmark' タブで定量比較が見られます。確認が終わったら教えてください。」

### ビューアーの画面構成

"Outputs" タブ：
- **Prompt**: 実行したタスク
- **Output**: スキルが生成したファイル（インライン表示）
- **Previous Output**（iteration 2+）: 前回のイテレーションの出力（折りたたみ）
- **Formal Grades**（採点済みの場合）: assertion の pass/fail（折りたたみ）
- **Feedback**: 自動保存されるテキストボックス
- **Previous Feedback**（iteration 2+）: 前回のコメント

"Benchmark" タブ：
- 各構成の pass rate、時間、トークン使用量の統計サマリー
- eval ごとの内訳とアナリストの観察

ナビゲーションは prev/next ボタンまたは矢印キー。完了時に "Submit All Reviews" で全フィードバックを `feedback.json` に保存。

### Step 5: フィードバックの読み取り

ユーザーが完了を知らせたら `feedback.json` を読む：

```json
{
  "reviews": [
    {"run_id": "eval-0-with_skill", "feedback": "the chart is missing axis labels", "timestamp": "..."},
    {"run_id": "eval-1-with_skill", "feedback": "", "timestamp": "..."},
    {"run_id": "eval-2-with_skill", "feedback": "perfect, love this", "timestamp": "..."}
  ],
  "status": "complete"
}
```

空のフィードバックは問題なしの意味。具体的な指摘があるテストケースに集中して改善する。

ビューアーサーバーが不要になったら停止する：

```bash
kill $VIEWER_PID 2>/dev/null
```

---

## スキルの改善

テストケースを実行し、ユーザーがレビューした後のフェーズ。フィードバックに基づいてスキルを改善する。

### 改善の考え方

1. **フィードバックを汎化する。** 少数の例で反復しているのは速度のためであり、それらの例だけで動くスキルは役に立たない。特定の例に過度に最適化する変更や、ALWAYS/NEVER の多用は避ける。頑固な問題には、別の切り口やパターンを試す。

2. **プロンプトを簡潔に保つ。** 効果のない指示は削除する。最終出力だけでなくトランスクリプトも読み、スキルがモデルに無駄な作業をさせていないか確認する。

3. **理由を説明する。** モデルに何かを求める際は、その理由を説明する。LLM は理由を理解すれば、硬直的な命令がなくても適切に判断できる。ユーザーのフィードバックが簡潔でも、タスクの本質を理解し、その理解を指示に反映させる。

4. **テストケース間の共通作業を探す。** 各テスト実行のトランスクリプトを読み、サブエージェントが同じようなヘルパースクリプトを独立して書いていないか確認する。3つのテストケース全てで同種のスクリプトが生成されていたら、それを `scripts/` にバンドルすべきシグナルである。

ドラフト改善は十分に検討してから行う。一度書いたら見直して改善する。

### イテレーションループ

スキル改善後：

1. 改善をスキルに適用する
2. 全テストケースを新しい `iteration-<N+1>/` ディレクトリで再実行する（baseline も含む）。新規スキル作成なら baseline は常に `without_skill`（スキルなし）。既存スキル改善なら、baseline はユーザーが持ち込んだ元のバージョンか前回のイテレーションか、適切に判断する。
3. `--previous-workspace` で前回のイテレーションを指定してビューアーを起動する
4. ユーザーのレビュー完了を待つ
5. フィードバックを読み、改善を繰り返す

終了条件：
- ユーザーが満足した
- フィードバックが全て空（全て問題なし）
- 有意な改善が見込めない

---

## 応用: ブラインド比較

2つのバージョンをより厳密に比較したい場合（例：「新バージョンは本当に良くなった？」）、ブラインド比較システムがある。`agents/comparator.md` と `agents/analyzer.md` を参照。2つの出力をどちらがどちらかを伏せた状態で独立エージェントに評価させ、勝者の理由を分析する。

任意機能であり、サブエージェントが必要。通常は人間によるレビューループで十分。

---

## Description の最適化

SKILL.md frontmatter の description フィールドは、Claude がスキルを起動するかどうかを決定する主要な仕組み。スキルの作成・改善後、description の最適化を提案する。

### Step 1: トリガー eval クエリの生成

should-trigger と should-not-trigger を混ぜた20個の eval クエリを作成する。JSON で保存：

```json
[
  {"query": "the user prompt", "should_trigger": true},
  {"query": "another prompt", "should_trigger": false}
]
```

クエリは実際のユーザーが入力しそうなリアルな内容にする。抽象的ではなく、具体的で詳細を含むもの — ファイルパス、業務の背景、カラム名、社名、URL など。長さを混在させ、明確なケースよりエッジケースを重視する。

悪い例: `"データを整形して"`, `"PDFからテキスト抽出"`, `"グラフを作って"`

良い例: `"上司から送られてきた xlsx ファイル（ダウンロードにある 'Q4売上_最終版v2.xlsx' みたいな名前）に、利益率を%で出す列を追加したい。売上が C 列でコストが D 列だったと思う"`

**should-trigger クエリ**（8〜10個）: 同じ意図の異なる表現をカバーする。フォーマル・カジュアル混在。スキル名やファイル形式を明示しないが明らかに必要なケースも含める。珍しいユースケースや、他のスキルとの競合ケースも入れる。

**should-not-trigger クエリ**（8〜10個）: 最も価値があるのはニアミスケース — スキルとキーワードや概念が重なるが実際には別のものが必要なクエリ。隣接ドメイン、曖昧な表現、別のツールが適切なケースなど。明らかに無関係なクエリ（PDF スキルに対して「フィボナッチ関数を書いて」など）は避ける。

### Step 2: ユーザーレビュー

HTML テンプレートで eval セットをユーザーに提示する：

1. `assets/eval_review.html` からテンプレートを読む
2. プレースホルダーを置換する：
   - `__EVAL_DATA_PLACEHOLDER__` → eval アイテムの JSON 配列（引用符なし — JS 変数代入）
   - `__SKILL_NAME_PLACEHOLDER__` → スキル名
   - `__SKILL_DESCRIPTION_PLACEHOLDER__` → 現在の description
3. 一時ファイルに書き出して開く（例: `/tmp/eval_review_<skill-name>.html`）: `open /tmp/eval_review_<skill-name>.html`
4. ユーザーがクエリの編集、should-trigger のトグル、追加/削除を行い、"Export Eval Set" をクリック
5. `~/Downloads/eval_set.json` にダウンロードされる — 複数ある場合（`eval_set (1).json` 等）は最新版を確認

eval クエリの質が description の質を決めるため、このステップは重要。

### Step 3: 最適化ループの実行

ユーザーに「時間がかかるため、バックグラウンドで最適化ループを実行し、定期的に進捗を報告します」と伝える。

eval セットをワークスペースに保存し、バックグラウンドで実行する：

```bash
python -m scripts.run_loop \
  --eval-set <path-to-trigger-eval.json> \
  --skill-path <path-to-skill> \
  --model <model-id-powering-this-session> \
  --max-iterations 5 \
  --verbose
```

model ID は現在のセッションを動かしているモデルを使用する（実際のユーザー体験と一致させるため）。

実行中、定期的に出力を tail してユーザーに進捗を報告する。

このスクリプトは最適化ループ全体を自動処理する。eval セットを 60% train / 40% test に分割し、現在の description を評価（各クエリ3回実行で安定したトリガー率を取得）、失敗したものに基づいて Claude に改善案を提案させる。新しい description を train と test の両方で再評価し、最大5回繰り返す。完了後、ブラウザで結果レポートを開き、`best_description` を含む JSON を返す — 過学習を避けるため train スコアではなく test スコアで選択される。

### スキルトリガーの仕組み

スキルは Claude の `available_skills` リストに name + description で表示され、Claude はその description を基にスキルを参照するか判断する。重要なのは、Claude は自力で簡単に処理できるタスクにはスキルを参照しないということ。「この PDF を読んで」のような単純な一手クエリは、description がマッチしていてもスキルを発火させないことがある。複雑で複数ステップを要するクエリや、専門的なクエリは description がマッチすれば確実にスキルを発火させる。

eval クエリは、Claude がスキルを参照する価値があるほど実質的な内容にする。

### Step 4: 結果の適用

JSON 出力の `best_description` を取得し、スキルの SKILL.md frontmatter を更新する。ユーザーに変更前後を見せ、スコアを報告する。

---

### パッケージと提示（`present_files` ツールが利用可能な場合のみ）

`present_files` ツールへのアクセスがあるか確認する。なければスキップ。あればスキルをパッケージして .skill ファイルをユーザーに提示する：

```bash
python -m scripts.package_skill <path/to/skill-folder>
```

パッケージ後、生成された `.skill` ファイルのパスをユーザーに案内する。

---

## Claude.ai 固有の手順

Claude.ai ではコアワークフロー（ドラフト → テスト → レビュー → 改善 → 繰り返し）は同じだが、サブエージェントがないため一部の手順が変わる。

**テスト実行**: サブエージェントがないため並列実行不可。各テストケースについて、スキルの SKILL.md を読み、その指示に従ってタスクを自分で実行する。1つずつ順番に。baseline 実行はスキップし、スキルを使ったタスク完了のみ行う。

**結果レビュー**: ブラウザが使えない場合、ビューアーをスキップし、会話内で結果を直接提示する。各テストケースのプロンプトと出力を表示する。ファイル出力（.docx, .xlsx 等）はファイルシステムに保存し、パスを案内する。インラインでフィードバックを求める。

**ベンチマーク**: 定量ベンチマークはスキップ（baseline 比較がサブエージェントなしでは意味をなさないため）。ユーザーの定性フィードバックに集中する。

**イテレーションループ**: 同じ流れ — スキル改善、テスト再実行、フィードバック取得 — ただしブラウザビューアーは使わない。ファイルシステムがあれば iteration ディレクトリで結果を整理可能。

**Description 最適化**: `claude` CLI ツール（`claude -p`）が必要であり、Claude Code でのみ利用可能。Claude.ai ではスキップ。

**ブラインド比較**: サブエージェントが必要。スキップ。

**パッケージ**: `package_skill.py` は Python とファイルシステムがあれば動作する。ユーザーは `.skill` ファイルをダウンロード可能。

**既存スキルの更新**: ユーザーが新規作成ではなく既存スキルの更新を求めている場合：
- **元の名前を維持する。** スキルのディレクトリ名と `name` frontmatter フィールドをそのまま使う。例: `research-helper` → `research-helper.skill`（`research-helper-v2` にしない）。
- **書き込み可能な場所にコピーしてから編集する。** インストール済みスキルのパスは読み取り専用の場合がある。`/tmp/skill-name/` にコピーして編集し、そこからパッケージする。
- **手動パッケージ時は `/tmp/` にステージングする。** 直接書き込みは権限エラーになることがある。

---

## Cowork 固有の手順

Cowork 環境での注意点：

- サブエージェントが使えるため、メインワークフロー（テスト並列実行、baseline 実行、採点等）は全て動作する。タイムアウト問題が深刻な場合は直列実行でもよい。
- ブラウザやディスプレイがないため、eval ビューアー生成時は `--static <output_path>` でスタンドアロン HTML を出力する。ユーザーにリンクを提示してブラウザで開いてもらう。
- テスト実行後は必ず `generate_review.py` で eval ビューアーを生成する（独自 HTML は書かない）。自分で結果を評価する前に、まずユーザーに結果を見せること。
- フィードバックの仕組みが異なる：サーバーがないため、"Submit All Reviews" ボタンで `feedback.json` がファイルとしてダウンロードされる。
- パッケージは動作する — `package_skill.py` は Python とファイルシステムがあればよい。
- Description 最適化（`run_loop.py` / `run_eval.py`）は `claude -p` を subprocess で使うため Cowork でも動作する。ただしスキルが完成してユーザーが同意してから実施する。
- **既存スキルの更新**: Claude.ai セクションの更新ガイダンスに従う。

---

## リファレンスファイル

agents/ ディレクトリには特化型サブエージェントの指示が含まれる。対応するサブエージェントを起動する際に読む。

- `agents/grader.md` — assertion の出力に対する評価方法
- `agents/comparator.md` — 2つの出力のブラインド A/B 比較方法
- `agents/analyzer.md` — 勝者の勝因分析方法

references/ ディレクトリには追加ドキュメントがある：
- `references/schemas.md` — evals.json, grading.json 等の JSON スキーマ定義

---

## コアループの再確認

1. スキルの目的を理解する
2. スキルをドラフトまたは編集する
3. テストプロンプトでスキル付き Claude を実行する
4. ユーザーと出力を評価する：
   - benchmark.json を作成し `eval-viewer/generate_review.py` でユーザーレビューを支援する
   - 定量 eval を実行する
5. 満足するまで繰り返す
6. 最終スキルをパッケージしてユーザーに返す

TodoList がある場合は、これらのステップを追加する。Cowork の場合は特に「evals JSON を作成し `eval-viewer/generate_review.py` でユーザーにテストケースをレビューしてもらう」を TodoList に入れること。
