class AddImageDataToDiaries < ActiveRecord::Migration[8.1]
  def change
    add_column :diaries, :image_data, :text
  end
end
