step 'there is a route with :n stops' do |n|
  @route = FactoryGirl.create(:route, stops_count: n.to_i)
end

step 'that route has a stop called :stop_name at position :n' do |stop_name, n|
  place = @route.stops[n.to_i].place
  place.name = stop_name
  place.save
end

step 'that route has :n :outward_or_return journey in :days days time' do |n, reversed, days|
  FactoryGirl.create_list(:journey, n.to_i, route: @route, reversed: reversed, start_time: DateTime.now + days.to_i.days)
end
