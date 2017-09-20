require 'rails_helper'

RSpec.describe PlacesController, type: :controller do
  render_views
    
  it 'returns all places' do
    FactoryGirl.create_list(:place, 5)
    
    get 'index', format: :json
    
    json = JSON.parse response.body
    
    expect(json.count).to eq(5)
  end
  
  it 'filters places by name' do
    FactoryGirl.create_list(:place, 5)
    origin = FactoryGirl.create(:place, name: 'Haverhill')
    
    FactoryGirl.create(:route, stops: [
      FactoryGirl.create(:stop),
      FactoryGirl.create(:stop, place: origin),
      FactoryGirl.create(:stop),
      FactoryGirl.create(:stop)
    ])

    get 'index', format: :json, query: 'Hav'
    
    json = JSON.parse response.body
    expect(json.count).to eq(1)
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
    
    get 'index', format: :json, origin_id: origin.id
    
    json = JSON.parse response.body
    expect(json.count).to eq(5)
  end
  
  it 'fiters places by origin and name' do
    origin = FactoryGirl.create(:place, name: 'Haverhill')
    
    FactoryGirl.create(:route, stops: [
      FactoryGirl.create(:stop, place: FactoryGirl.create(:place, name: 'Newmarket')),
      FactoryGirl.create(:stop),
      FactoryGirl.create(:stop),
      FactoryGirl.create(:stop, place: origin),
    ])
    
    get 'index', format: :json, origin_id: origin.id, query: 'new'
    
    json = JSON.parse response.body
    expect(json.count).to eq(1)
  end
  
end
