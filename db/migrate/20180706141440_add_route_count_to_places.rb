class AddRouteCountToPlaces < ActiveRecord::Migration[4.2]
  def change
    add_column :places, :route_count, :integer
    
    Place.reset_column_information
    Place.all.each do |p|
      Place.update_counters p.id, :route_count => p.routes.length
    end
  end
end
