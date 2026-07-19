class AddIsbnAndPurchasePriceToBooks < ActiveRecord::Migration[8.1]
  def change
    add_column :books, :isbn, :string
    add_column :books, :purchase_price, :integer
  end
end
