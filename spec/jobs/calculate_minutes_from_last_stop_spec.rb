require 'rails_helper'

RSpec.describe CalculateMinutesFromLastStop, type: :model, webmock: true do
  
  let(:place1) { FactoryGirl.create(:place, latitude:52.24488, longitude:0.407962)}
  let(:place2) { FactoryGirl.create(:place, latitude:52.222596, longitude:0.462666)}
  let(:route) { FactoryGirl.create(:route, stops_count: 0) }
  let!(:stops) {
    [
      FactoryGirl.create(:stop, place: place1, route: route, minutes_from_last_stop: nil),
      FactoryGirl.create(:stop, place: place2, route: route, minutes_from_last_stop: nil)
    ]
  }
  
  before do
    stub_request(:get, /https:\/\/api\.mapbox\.com\/directions\/v5\/mapbox\/driving\/0\.462666,52\.222596;0\.407962,52\.24488\.json\?access_token=.+/).to_return(body: get_fixture('directions.json'))
  end
  
  it 'gets the minutes from the last stop for a stop' do
    CalculateMinutesFromLastStop.run(stops[1].id)
    stops[1].reload
    expect(stops[1].minutes_from_last_stop).to eq(7)
  end
  
  it 'returns 0 if a stop is the first stop' do
    CalculateMinutesFromLastStop.run(stops[0].id)
    stops[0].reload
    expect(stops[0].minutes_from_last_stop).to eq(nil)
  end
  
  it 'does not overwrite minutes_from_last_stop if already set' do
    stops[1].minutes_from_last_stop = 40
    stops[1].save
    CalculateMinutesFromLastStop.run(stops[1].id)
    expect(stops[1].minutes_from_last_stop).to eq(40)
  end

  
end
