class AddColumnStatusToRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :requests, :status, :boolean, default: false
  end
end
