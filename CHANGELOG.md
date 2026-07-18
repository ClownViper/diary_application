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

## 2026-07-18 紺色テーマへ変更
- `@theme` の3スケールを紺系に差し替え（gray=クール紙色 / slate=インク紺 / clay=瑠璃アクセント）
- Chart.js直書き色（ダッシュボード・体調グラフ）、theme-colorメタ、PWA manifestの色も追随
- スクショ確認済み（ログイン・ダッシュボード・日記一覧）

## 2026-07-19 レイアウト・カードデザイン見直し
- ダッシュボードを9カード→4カードに再構成（今日の記録ヒーローカード + 今月の出費 / 体重の推移 / 読書中）。最近の日記・出費、ミニカレンダーは一覧・カレンダーと重複のため削除
- カードスタイルを `rounded-xl border shadow-sm` に全画面統一
- コンテンツ幅を全画面 `max-w-4xl` に統一（CSV画面が3xlでずれていた）・カレンダーに共通ページヘッダー追加
- 出費一覧の品目・カテゴリに truncate 追加（長文時のはみ出し防止）
- RSpec 50件・rubocop 0件・全主要画面スクショ確認済み

## 2026-07-19 ダッシュボード再々構成・詳細/編集画面の整列
- ダッシュボードを機能ごとに1カードへ統合（出費=今日+今月+予算、体調=今日+体重グラフ）。情報の重複を解消
- 今日の日記はスリムバー化して最上部に（書く/編集ボタン付き）
- 詳細/編集画面の戻るリンク・見出しをコンテンツ幅（max-w-4xl）に整列（back_link/form_pageパーシャル修正で全ページ一括）
- RSpec 50件・rubocop 0件・スクショ確認済み
