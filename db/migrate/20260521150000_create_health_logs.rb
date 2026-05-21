# 体重・体調ログテーブルの作成
class CreateHealthLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :health_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.date :date, null: false
      t.decimal :weight, precision: 5, scale: 1
      t.integer :condition
      t.string :memo, limit: 100

      t.timestamps
    end

    add_index :health_logs, [ :user_id, :date ], unique: true
  end
end
