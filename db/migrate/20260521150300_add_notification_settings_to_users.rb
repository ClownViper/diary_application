# ユーザーテーブルに通知設定カラムを追加
class AddNotificationSettingsToUsers < ActiveRecord::Migration[8.1]
  def change
    # 日記通知
    add_column :users, :notify_diary, :boolean, default: false
    add_column :users, :notify_diary_time, :time

    # 家計簿通知
    add_column :users, :notify_entry, :boolean, default: false
    add_column :users, :notify_entry_time, :time

    # 体調ログ通知
    add_column :users, :notify_health, :boolean, default: false
    add_column :users, :notify_health_time, :time

    # 読書ログ通知
    add_column :users, :notify_books, :boolean, default: false
    add_column :users, :notify_books_time, :time

    # スケジュール通知
    add_column :users, :notify_schedule, :boolean, default: false
    add_column :users, :notify_schedule_before, :integer, default: 10
  end
end
