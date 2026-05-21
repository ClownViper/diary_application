# 読書ログテーブルの作成
class CreateBooks < ActiveRecord::Migration[8.1]
  def change
    create_table :books do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.string :author
      t.integer :status, default: 0, null: false
      t.date :started_on
      t.date :finished_on
      t.text :memo

      t.timestamps
    end

    add_index :books, [ :user_id, :status ]
  end
end
