class UnifyUserIdTypesToBigintAndAddExpensesDateIndex < ActiveRecord::Migration[8.1]
  def change
    change_column :categories, :user_id, :bigint
    change_column :diaries,    :user_id, :bigint
    change_column :expenses,   :user_id, :bigint

    add_index :expenses, [ :user_id, :date ], name: "index_expenses_on_user_id_and_date"
  end
end
