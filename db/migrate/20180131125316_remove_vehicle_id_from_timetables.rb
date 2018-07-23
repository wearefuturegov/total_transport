class RemoveVehicleIdFromTimetables < ActiveRecord::Migration[4.2]
  def change
    remove_column :timetables, :vehicle_id
  end
end
