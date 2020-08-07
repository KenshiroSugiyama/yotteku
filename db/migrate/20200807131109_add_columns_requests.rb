class AddColumnsRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :requests, :freedrink, :boolean
    add_column :requests, :situation, :string
    add_column :requests, :foodamount, :string
    add_column :requests, :drinktime, :string
  end
end
