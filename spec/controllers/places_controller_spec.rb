require 'rails_helper'

RSpec.describe PlacesController, type: :controller do
  render_views
    
  it 'returns all places' do
    FactoryGirl.create_list(:place, 5)
    
    get 'index', format: :json
    
    json = JSON.parse response.body
    
    expect(json.count).to eq(5)
  end
  
  it 'filters places by origin' do
    FactoryGirl.create_list(:route, 5, stops_count: 7)
    
    origin = FactoryGirl.create(:place, name: 'Haverhill')
    
    FactoryGirl.create(:route, stops: [
      FactoryGirl.create(:stop),
      FactoryGirl.create(:stop, place: origin),
      FactoryGirl.create(:stop),
      FactoryGirl.create(:stop)
    ])
    
    FactoryGirl.create(:route, stops: [
      FactoryGirl.create(:stop),
      FactoryGirl.create(:stop, place: origin),
      FactoryGirl.create(:stop)
    ])
    
    get 'index', format: :json, origin: origin.slug
    
    json = JSON.parse response.body
    expect(json.count).to eq(5)
  end
  
end
