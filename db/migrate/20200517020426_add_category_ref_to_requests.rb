class AddCategoryRefToRequests < ActiveRecord::Migration[5.2]
  def change
    add_reference :requests, :category
  end
end
