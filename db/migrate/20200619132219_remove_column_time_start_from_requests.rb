class RemoveColumnTimeStartFromRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :requests, :time, :string
    remove_column :requests, :time_start,:integer
    remove_column :requests, :time_end,:integer
    remove_column :requests, :category,:string
    remove_column :requests, :people,:integer
  end
end
