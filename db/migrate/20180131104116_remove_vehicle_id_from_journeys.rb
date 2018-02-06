class RemoveVehicleIdFromJourneys < ActiveRecord::Migration
  def change
    remove_column :journeys, :vehicle_id
  end
end
