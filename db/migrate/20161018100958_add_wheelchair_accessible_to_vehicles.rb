class AddWheelchairAccessibleToVehicles < ActiveRecord::Migration[4.2]
  def change
    add_column :vehicles, :wheelchair_accessible, :boolean
  end
end
