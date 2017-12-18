require 'rails_helper'

RSpec.describe SetRouteGeometry, type: :model, webmock: true do
  
  let(:place1) { FactoryBot.create(:place, latitude:52.24488, longitude:0.407962)}
  let(:place2) { FactoryBot.create(:place, latitude:52.222596, longitude:0.462666)}
  let(:route) { FactoryBot.create(:route, stops_count: 0) }
  let!(:stops) {
    [
      FactoryBot.create(:stop, place: place1, route: route, minutes_from_last_stop: nil),
      FactoryBot.create(:stop, place: place2, route: route, minutes_from_last_stop: nil)
    ]
  }
  
  before do
    stub_request(:get, /https:\/\/api\.mapbox\.com\/directions\/v5\/mapbox\/driving\/0\.407962,52\.24488;0\.462666,52\.222596\.json\?access_token=.+/).to_return(body: get_fixture('directions_service/directions.json'))
  end
  
  it 'sets the geometry correctly' do
    SetRouteGeometry.run(route.id)
    route.reload
    expect(route.geometry).to_not be_nil
    expect(route.geometry).to be_a(Array)
  end
  
  it 'does nothing if there is only one stop' do
    route.stops = [stops[0]]
    route.save
    SetRouteGeometry.run(route.id)
    route.reload
    expect(route.geometry).to be_nil
  end
  
end
