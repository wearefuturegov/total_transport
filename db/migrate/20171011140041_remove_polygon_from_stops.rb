class RemovePolygonFromStops < ActiveRecord::Migration
  def change
    remove_column :stops, :polygon, :json
  end
end
