class AddGeometryToRoute < ActiveRecord::Migration
  def change
    add_column :routes, :geometry, :json
  end
end
