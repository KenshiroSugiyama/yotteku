class AddColumnRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :requests,:res_id,:integer
  end
end
