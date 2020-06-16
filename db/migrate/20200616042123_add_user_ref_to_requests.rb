class AddUserRefToRequests < ActiveRecord::Migration[5.2]
  def change
    add_reference :requests, :user
  end
end
