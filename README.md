# claude-code-for-repository-talk
> ref. https://docs.anthropic.com/ja/docs/claude-code/sdk

# 何をするためのもの？
リポジトリに対してClaude Codeを使ったコード仕様をReadできるAIを追加する仕組みです。  
GitHub外部から実行して結果を取得できる点、Write権限を持たない点が特徴です。  
運用エンジニアが安全なGitHub権限のもとで仕様を確認するために用います。

# セットアップ
> ref. https://docs.anthropic.com/ja/docs/claude-code/sdk

- Claude から `ANTHROPIC_API_KEY` を取得しGitHub Secretに格納

# 🤖 AI機能の使い方

## 基本的な使用方法

```bash
# リポジトリについてClaudeに質問
make ai "このリポジトリの概要を教えて"

# コードの解析を依頼
make ai "main.pyの機能について詳しく説明して"

# 複数のファイルについて質問
make ai "srcディレクトリ内のPythonファイルの役割を教えて"
```

## システムプロンプトのカスタマイズ

```bash
# コードレビューアーとして動作させる
SYSTEM_PROMPT="あなたは優秀なコードレビュアーです。セキュリティとパフォーマンスの観点から分析してください" make ai "このコードの改善点を教えて"

# 技術文書作成者として動作させる
SYSTEM_PROMPT="あなたは技術文書の専門家です。わかりやすい説明を心がけて回答してください" make ai "このプロジェクトのアーキテクチャを説明して"

# 初心者向けの説明者として動作させる
SYSTEM_PROMPT="プログラミング初心者にもわかりやすく、具体例を交えて説明してください" make ai "このコードは何をしているの？"
```

## 実行の流れ

1. **🚀 クエリの送信**: GitHub Actionsにクエリを送信
2. **⏳ 実行監視**: Actionの実行状況をリアルタイムで監視
3. **📋 結果表示**: 完了後、Actionのログから結果を直接取得して表示

## 便利な使用例

### 📝 ドキュメント生成
```bash
make ai "このプロジェクトのREADMEを改善するための提案をして"
```

### 🔍 コード解析
```bash
make ai "バグの可能性がある箇所を特定して"
SYSTEM_PROMPT="セキュリティ専門家として" make ai "脆弱性はありますか？"
```

### 🔍 Issue検索
```bash
make ai "このプロジェクトではどのようなIssueが起票されていますか？"
```

### 🏗️ アーキテクチャ理解
```bash
make ai "このプロジェクトの全体的な構造と各ファイルの役割を教えて"
```

### 🚀 改善提案
```bash
SYSTEM_PROMPT="パフォーマンス最適化の専門家として" make ai "コードの最適化ポイントを教えて"
```

## 必要な準備

- [GitHub CLI](https://cli.github.com/) がインストールされていること
- `jq` コマンドが利用可能であること
- GitHub Actions での `ANTHROPIC_API_KEY` が設定されていること

## 注意事項

- 実行にはGitHub Actionsの実行時間が消費されます
- Claude APIの利用料金が発生します
- 大きなリポジトリの場合、実行に時間がかかる場合があります

# 一般のリポジトリに構成する
`./template` のファイルを既存のリポジトリに追加、もしくはコードをマージしてください。