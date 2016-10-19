class AddWheelchairAccessibleToVehicles < ActiveRecord::Migration
  def change
    add_column :vehicles, :wheelchair_accessible, :boolean
  end
end
