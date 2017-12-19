class AddRouteIdToRoutes < ActiveRecord::Migration
  def change
    add_reference :routes, :route, index: true
  end
end
