# コンテンツ設定マイグレーション
# 各機能のON/OFFフラグと出費目安金額をusersテーブルに追加
class AddContentSettingsToUsers < ActiveRecord::Migration[8.1]
  def change
    # 機能ごとのON/OFFフラグ（デフォルトはすべてON）
    add_column :users, :feature_diary, :boolean, default: true, null: false
    add_column :users, :feature_expense, :boolean, default: true, null: false
    add_column :users, :feature_health_log, :boolean, default: true, null: false
    add_column :users, :feature_book, :boolean, default: true, null: false
    add_column :users, :feature_schedule, :boolean, default: true, null: false

    # 出費目安金額（月額、デフォルト150,000円）
    add_column :users, :expense_target, :integer, default: 150_000, null: false
  end
end
