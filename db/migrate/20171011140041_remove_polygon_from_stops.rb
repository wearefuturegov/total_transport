class RemovePolygonFromStops < ActiveRecord::Migration[4.2]
  def change
    remove_column :stops, :polygon, :json
  end
end
