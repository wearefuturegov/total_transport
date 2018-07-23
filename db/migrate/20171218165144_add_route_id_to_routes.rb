class AddRouteIdToRoutes < ActiveRecord::Migration[4.2]
  def change
    add_reference :routes, :route, index: true
  end
end
