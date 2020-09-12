class CreateScoutTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :scout_templates do |t|
      t.string :name
      t.integer :restaurant_id
      t.string :beer
      t.integer :price
      t.string :start_time
      t.string :drink_time
      t.string :content
      t.string :hope
      t.timestamps
    end
  end
end
