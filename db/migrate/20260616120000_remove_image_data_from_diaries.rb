class RemoveImageDataFromDiaries < ActiveRecord::Migration[8.1]
  def change
    remove_column :diaries, :image_data, :text
  end
end
