class AddDefaultToRouteGeometry < ActiveRecord::Migration[4.2]
  def change
    change_column_default :routes, :geometry, []
  end
end
