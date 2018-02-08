require 'rails_helper'

RSpec.describe PlacesController, type: :controller, que: true do
  render_views
    
  it 'returns all places' do
    FactoryBot.create_list(:place, 5)
    
    get 'index', format: :json
    
    json = JSON.parse response.body
    
    expect(json.count).to eq(5)
  end
  
  it 'searches places' do
    FactoryBot.create_list(:place, 5)
    
    place = FactoryBot.create(:place, name: 'Some place')
    
    FactoryBot.create(:route, stops: [
      FactoryBot.create(:stop),
      FactoryBot.create(:stop),
      FactoryBot.create(:stop),
      FactoryBot.create(:stop, place: place),
      FactoryBot.create(:stop),
    ])
    
    FactoryBot.create(:route, stops: [
      FactoryBot.create(:stop),
      FactoryBot.create(:stop, place: place),
      FactoryBot.create(:stop),
      FactoryBot.create(:stop),
    ])
        
    get 'index', format: :json, query: 'so'
    
    json = JSON.parse response.body
    
    expect(json.count).to eq(1)
    expect(json.first['name']).to eq('Some place')
    expect(json.first['route_count']).to eq(2)
  end
  
end
