class ReChangeColumnRequestIdToScouts < ActiveRecord::Migration[5.2]
  def change
    add_reference :scouts, :request
  end
end
