class AddDefaultToRouteGeometry < ActiveRecord::Migration
  def change
    change_column_default :routes, :geometry, []
  end
end
