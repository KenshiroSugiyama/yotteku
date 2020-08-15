class ChangeColumnRequestIdToScouts < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :scouts, :requests
    remove_index :scouts, :request_id
    remove_reference :scouts, :request
  end
end
