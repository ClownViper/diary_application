# スケジュールテーブルの作成
class CreateSchedules < ActiveRecord::Migration[8.1]
  def change
    create_table :schedules do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.date :date, null: false
      t.time :start_time
      t.time :end_time
      t.string :memo, limit: 200

      t.timestamps
    end

    add_index :schedules, [ :user_id, :date ]
  end
end
