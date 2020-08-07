class ChangeDataFreedrinkToRequests < ActiveRecord::Migration[5.2]
  def change
    change_column :requests, :freedrink, :string
  end
end
