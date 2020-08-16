class ChangeColumnToRequests < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :requests, :scouts
    remove_index :requests, :scout_id
    remove_reference :requests, :scout
    add_column :requests, :scout_id, :integer
  end
end
