# Changelog

## 2026-07-18 リポジトリ整理 + デモ公開準備

### 整理系
- 不要ブランチ削除（ローカル: `backup-main`・`refactor/timezone-and-fixes`、リモート追跡: devin系6本・dependabot系2本をprune）
- 秘密情報チェック（履歴・現ツリーともに問題なし。`.kamal/secrets` は標準テンプレのみ）
- `docs/spec.md` をローカル管理（`~/workspace/kiji/life-log/`）へ移動
- rubocop指摘 46件を解消（全ファイル指摘ゼロ）
- N+1修正: ダッシュボード直近支出・カレンダーレイヤーに `includes(:category)`、日記一覧に `with_attached_image`
- 未使用の空 `test/` ディレクトリを削除（テストはRSpecに一本化）
- README: セットアップ手順を実態に合わせ修正（`npm install`・`db:seed`・`bin/dev`）、デモアカウント・新規登録無効化の記載を追加

### デモ公開準備
- 新規登録を可逆的に無効化（`routes.rb` の `skip: [:registrations]` + ログイン画面リンクの `if false` ガード。戻し方はREADME参照）
- ログイン画面にデモアカウント情報（test@example.com / password）を表示（ja/en対応）

### 確認
- RSpec: 50 examples, 0 failures ／ rubocop: no offenses
- ログインフロー実機確認（サインイン→ダッシュボード表示OK）
