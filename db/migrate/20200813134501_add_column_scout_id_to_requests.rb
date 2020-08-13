class AddColumnScoutIdToRequests < ActiveRecord::Migration[5.2]
  def change
    add_reference :requests,:scout,foreign_key: true
  end
end
