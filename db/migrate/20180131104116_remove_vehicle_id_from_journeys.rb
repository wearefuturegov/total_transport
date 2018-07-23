class RemoveVehicleIdFromJourneys < ActiveRecord::Migration[4.2]
  def change
    remove_column :journeys, :vehicle_id
  end
end
