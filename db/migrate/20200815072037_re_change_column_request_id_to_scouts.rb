class ReChangeColumnRequestIdToScouts < ActiveRecord::Migration[5.2]
  def change
    add_column :scouts, :request_id, :integer
  end
end
