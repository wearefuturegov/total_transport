class SetRouteGeometry < Que::Job

  def run(route_id)
    route = Route.find(route_id)
    ActiveRecord::Base.transaction do
      if route.stops.count > 1
        latlngs = stops(route)
        route.update_column(:geometry, DirectionsService.new(latlngs).geometry)
      end
    end
  end
  
  def stops(route)
    route.stops.map do |s|
      [s.place.longitude, s.place.latitude].join(',')
    end
  end

end
