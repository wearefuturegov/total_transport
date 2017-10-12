require 'rails_helper'

RSpec.describe PlacesController, type: :controller, que: true do
  render_views
    
  it 'returns all places' do
    FactoryGirl.create_list(:place, 5)
    
    get 'index', format: :json
    
    json = JSON.parse response.body
    
    expect(json.count).to eq(5)
  end
  
  it 'searches places' do
    FactoryGirl.create_list(:place, 5)
    
    place = FactoryGirl.create(:place, name: 'Some place')
    
    FactoryGirl.create(:route, stops: [
      FactoryGirl.create(:stop),
      FactoryGirl.create(:stop),
      FactoryGirl.create(:stop),
      FactoryGirl.create(:stop, place: place),
      FactoryGirl.create(:stop),
    ])
    
    FactoryGirl.create(:route, stops: [
      FactoryGirl.create(:stop),
      FactoryGirl.create(:stop, place: place),
      FactoryGirl.create(:stop),
      FactoryGirl.create(:stop),
    ])
        
    get 'index', format: :json, query: 'so'
    
    json = JSON.parse response.body
    
    expect(json.count).to eq(1)
    expect(json.first['name']).to eq('Some place')
    expect(json.first['routes'].count).to eq(2)
  end
  
end
