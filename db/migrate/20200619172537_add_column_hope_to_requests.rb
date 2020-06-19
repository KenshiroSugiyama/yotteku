class AddColumnHopeToRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :requests, :hope, :string
  end
end
