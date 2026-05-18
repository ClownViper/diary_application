class CreateDiaries < ActiveRecord::Migration[8.1]
  def change
    create_table :diaries do |t|
      t.string :title
      t.text :body
      t.date :date
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
