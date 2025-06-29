# claude-code-for-repository-talk
> ref. https://docs.anthropic.com/ja/docs/claude-code/sdk

# 何をするためのもの？
リポジトリに対してClaude Codeを使ったコード仕様をReadできるAIを追加する仕組みです。  
GitHub外部から実行して結果を取得できる点、Write権限を持たない点が特徴です。  
運用エンジニアが安全なGitHub権限のもとで仕様を確認するために用います。

# セットアップ
> ref. https://docs.anthropic.com/ja/docs/claude-code/sdk

- Claude から `ANTHROPIC_API_KEY` を取得しGitHub Secretに格納

# 一般のリポジトリに構成する
`./template` のファイルを既存のリポジトリに追加、もしくはコードをマージしてください。