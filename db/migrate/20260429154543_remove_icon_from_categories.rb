class RemoveIconFromCategories < ActiveRecord::Migration[8.1]
  def change
    remove_column :categories, :icon, :string
  end
end
