class AddUniqueIndexToDiaries < ActiveRecord::Migration[8.1]
  def change
    add_index :diaries, [:user_id, :date], unique: true
  end
end
