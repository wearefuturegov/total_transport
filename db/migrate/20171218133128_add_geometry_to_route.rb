class AddGeometryToRoute < ActiveRecord::Migration[4.2]
  def change
    add_column :routes, :geometry, :json
  end
end
