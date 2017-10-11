module RouteSteps
  step :stub_placename, 'the placename service has a place called :placename'

  step 'there is a route with :n stops' do |n|
    @route = FactoryGirl.create(:route, stops_count: n.to_i)
  end

  step 'that route has a stop called :stop_name at position :n' do |stop_name, n|
    place = @route.stops[n.to_i].place
    place.name = stop_name
    place.os_id = stop_name
    place.save
    # Stub the placenames service to return only the expected results so we're
    # not hitting the live API
    stub_placename(stop_name)
  end

  step 'that route has :n :outward_or_return journey in :days days time' do |n, reversed, days|
    FactoryGirl.create_list(:journey, n.to_i, route: @route, reversed: reversed, start_time: DateTime.now + days.to_i.days)
  end

  def stub_placename(placename)
    allow(::PlacenamesService).to receive(:new).with(placename) {
      double = double(::PlacenamesService)
      allow(double).to receive(:search) {
        [
          {
            'ID': placename,
            'NAME1': placename
          }
        ]
      }
      double
    }
  end
end

RSpec.configure do |config|
  config.include RouteSteps, type: :feature
end
