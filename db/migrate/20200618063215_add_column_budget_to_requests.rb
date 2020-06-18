class AddColumnBudgetToRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :requests,:budget,:string
    add_column :requests,:people,:integer
    remove_column :requests,:price_min,:integer
    remove_column :requests,:price_max,:integer
  end
end
