class AddNewIndexesToStops < ActiveRecord::Migration
  def change
    add_index :stops, [:place_id, :route_id]
  end
end
