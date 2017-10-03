FactoryGirl.define do
  factory(:stop) do
    place
    route
    polygon({"type" => "FeatureCollection", "features" => [{"type" => "Feature", "geometry" => {"type" => "Polygon", "coordinates" => [[[0.87615966796875, 51.73112162128191], [0.8842277526855469, 51.71708534339445], [0.8996772766113281, 51.716872639002936], [0.9094619750976562, 51.723678683307185], [0.9019088745117188, 51.739094837832475], [0.8914375305175781, 51.74175226408898], [0.87615966796875, 51.73112162128191]]]}, "properties" => {}}]})
    minutes_from_last_stop 20

    sequence(:position) { |n| n }
    
    after(:build) { |stop| stop.class.skip_callback(:create, :after, :queue_minutes_from_last_stop) }
    
    factory(:stop_with_callback) do
      after(:create) { |stop| stop.send(:queue_minutes_from_last_stop) }
    end
  end
end
