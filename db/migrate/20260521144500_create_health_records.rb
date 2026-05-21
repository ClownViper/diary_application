class CreateHealthRecords < ActiveRecord::Migration[8.1]
  def change
    create_table :health_records do |t|
      t.references :user, null: false, foreign_key: true
      t.date :date, null: false
      t.decimal :weight, precision: 5, scale: 1
      t.decimal :height, precision: 5, scale: 1
      t.decimal :body_temperature, precision: 3, scale: 1
      t.integer :systolic_pressure
      t.integer :diastolic_pressure
      t.text :memo

      t.timestamps
    end

    add_index :health_records, [ :user_id, :date ], unique: true
  end
end
