class AddUIdToRestaurants < ActiveRecord::Migration[5.2]
  def change
    add_column :restaurants, :uid, :string
    add_column :requests, :req_status,:boolean,default: false
  end
end
