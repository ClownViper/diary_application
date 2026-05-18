class ChangeCategoryIdNullableInExpenses < ActiveRecord::Migration[7.1]
  def change
    change_column_null :expenses, :category_id, true
  end
end