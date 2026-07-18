[日本語](#mydiary-1) | [English](#mydiary)

---

# MyDiary

A personal life-logging app built with Ruby on Rails. Combines diary, expense tracking, health log, reading log, and schedule management in one place.

**Live demo:** *(URL here)*

---

## Features

- **Diary** — Daily entries with image attachments
- **Expense tracking** — Log expenses with categories and monthly budget
- **Health log** — Track weight, condition, sleep, and temperature with graphs
- **Reading log** — Book management with ISBN barcode scanning
- **Schedule** — Event management with calendar view
- **Calendar** — Monthly overview of all records
- **Web Push notifications** — Reminders per feature, configurable per user
- **PWA** — Installable on iPhone home screen
- **i18n** — Japanese / English

---

## Tech Stack

| Category | Technology |
|----------|-----------|
| Language | Ruby 4.0.0 |
| Framework | Rails 8.1 |
| Database | PostgreSQL |
| Frontend | Hotwire (Turbo + Stimulus), Tailwind CSS |
| Auth | Devise |
| Job queue | SolidQueue (runs inside Puma) |
| Image storage | Cloudinary + Active Storage |
| Push notifications | Web Push (VAPID) |
| Deployment | Render (Docker) |

---

## Getting Started

### Prerequisites

- Ruby 4.0.0
- PostgreSQL
- Node.js

### Setup

```bash
git clone https://github.com/ClownViper/diary_application.git
cd diary_application
bundle install
```

Copy `.env.example` to `.env` and fill in the required values (see Environment Variables below).

```bash
npm install
bundle exec rails db:create db:migrate db:seed
bin/dev
```

Open `http://localhost:3000`.

`db:seed` creates a demo account (`test@example.com` / `password`) with sample data. Sign-up is currently disabled for the public demo; re-enable it by removing `skip: [:registrations]` in `config/routes.rb` and the `if false` guard in `app/views/devise/sessions/new.html.erb`.

---

## Environment Variables

| Variable | Description |
|----------|-------------|
| `DATABASE_URL` | PostgreSQL connection string |
| `RAILS_MASTER_KEY` | Key to decrypt `config/credentials.yml.enc` |
| `CLOUDINARY_URL` | Cloudinary connection string |
| `SOLID_QUEUE_IN_PUMA` | Set to `true` to run SolidQueue inside Puma |
| `TZ` | Timezone (e.g. `Asia/Tokyo`) |

VAPID keys for Web Push are stored in Rails credentials:

```yaml
webpush:
  public_key: "..."
  private_key: "..."
  subject: "mailto:your@email.com"
```

---

## Deployment

Deployed on Render using Docker. Configuration is in `render.yaml`.

Migrations run automatically on deploy via the release command:

```bash
bundle exec rails db:migrate
```

---

## Development Articles (Japanese)

A series of articles documenting the development process:

1. [Claude Codeで個人Railsアプリを作った話]()
2. [多言語対応とFlatpickrでdate inputの問題を解決した話]()
3. [ISBNバーコードスキャンで書籍情報を自動入力する]()
4. [RailsアプリをPWA化してWeb Push通知を実装した話]()
5. [RenderへのデプロイでSolidQueue・環境変数・Push通知にハマった話]()

---
---

# MyDiary

Ruby on Railsで作ったライフログアプリ。日記・家計管理・体調記録・読書ログ・スケジュールをひとつにまとめた個人用アプリです。

**デモ:** *(URLをここに)*

---

## 機能

- **日記** — 画像添付付きの日記記録
- **家計管理** — カテゴリ・月次予算つきの支出管理
- **体調ログ** — 体重・体調・睡眠・体温の記録とグラフ表示
- **読書ログ** — ISBNバーコードスキャンで書籍情報を自動入力
- **スケジュール** — カレンダー付きのイベント管理
- **カレンダー** — 全記録の月次ビュー
- **Web Push通知** — 機能ごとに通知時刻を設定できるリマインダー
- **PWA** — iPhoneのホーム画面にインストール可能
- **多言語対応** — 日本語 / 英語

---

## 技術スタック

| カテゴリ | 技術 |
|---------|------|
| 言語 | Ruby 4.0.0 |
| フレームワーク | Rails 8.1 |
| データベース | PostgreSQL |
| フロントエンド | Hotwire (Turbo + Stimulus), Tailwind CSS |
| 認証 | Devise |
| ジョブキュー | SolidQueue（Puma内で動作） |
| 画像ストレージ | Cloudinary + Active Storage |
| Push通知 | Web Push（VAPID） |
| デプロイ | Render（Docker） |

---

## ローカル起動

### 必要なもの

- Ruby 4.0.0
- PostgreSQL
- Node.js

### セットアップ

```bash
git clone https://github.com/ClownViper/diary_application.git
cd diary_application
bundle install
```

`.env.example` を `.env` にコピーして必要な値を入力（下記「環境変数」参照）。

```bash
npm install
bundle exec rails db:create db:migrate db:seed
bin/dev
```

`http://localhost:3000` をブラウザで開く。

`db:seed` でデモアカウント（`test@example.com` / `password`）とサンプルデータが作成される。デモ公開のため新規登録は無効化中。戻す場合は `config/routes.rb` の `skip: [:registrations]` と `app/views/devise/sessions/new.html.erb` の `if false` ガードを外す。

---

## 環境変数

| 変数名 | 説明 |
|--------|------|
| `DATABASE_URL` | PostgreSQLの接続文字列 |
| `RAILS_MASTER_KEY` | `config/credentials.yml.enc` を復号する鍵 |
| `CLOUDINARY_URL` | Cloudinaryの接続文字列 |
| `SOLID_QUEUE_IN_PUMA` | `true` にするとPuma内でSolidQueueが起動 |
| `TZ` | タイムゾーン（例: `Asia/Tokyo`） |

Web Push用のVAPID鍵はRails credentialsに保存：

```yaml
webpush:
  public_key: "..."
  private_key: "..."
  subject: "mailto:your@email.com"
```

---

## デプロイ

RenderにDockerでデプロイ。設定は `render.yaml` に記述。

デプロイ時にリリースコマンドでマイグレーションが自動実行される：

```bash
bundle exec rails db:migrate
```

---

## 開発記事

※ 記事・スクショ等のドキュメント類はローカル管理（`~/workspace/kiji/life-log/`）。

このアプリの開発について書いた記事シリーズ：

1. [Claude Codeで個人Railsアプリを作った話](https://zenn.dev/clown_viper/books/482693b5bb9af8)
