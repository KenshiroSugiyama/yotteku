class CreateRestaurantInformations < ActiveRecord::Migration[5.2]
  def change
    create_table :restaurant_informations do |t|
      t.references :restaurant, foreign_key: true
      t.integer :price_min
      t.integer :price_max
      t.string :menu
      t.string :address
      t.string :url
      t.timestamps
    end
  end
end
