class CreateRestaurants < ActiveRecord::Migration[5.2]
  def change
    create_table :restaurants do |t|
      t.string :name
      t.integer :phone_number
      t.references :category, foreign_key: true
      t.timestamps
    end
  end
end
