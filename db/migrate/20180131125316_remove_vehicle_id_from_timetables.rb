class RemoveVehicleIdFromTimetables < ActiveRecord::Migration
  def change
    remove_column :timetables, :vehicle_id
  end
end
