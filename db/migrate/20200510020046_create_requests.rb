class CreateRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :requests do |t|
      t.string :category
      t.integer :price_min
      t.integer :price_max
      t.integer :number_of_people
      t.integer :time_start
      t.integer :time_end
      t.timestamps
    end
  end
end
