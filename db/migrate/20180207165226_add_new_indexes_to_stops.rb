class AddNewIndexesToStops < ActiveRecord::Migration[4.2]
  def change
    add_index :stops, [:place_id, :route_id]
  end
end
