class CreateScouts < ActiveRecord::Migration[5.2]
  def change
    create_table :scouts do |t|
      t.references :restaurant, foreign_key: true
      t.references :request, foreign_key: true
      t.string :name
      t.integer :price
      t.string :beer
      t.string :start_time
      t.string :drink_time
      t.string :content
      t.string :hope
      t.timestamps
    end
  end
end
