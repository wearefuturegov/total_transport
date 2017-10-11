require 'rails_helper'

RSpec.describe JourneysController, type: :controller do
  
  let(:origin) { FactoryGirl.create(:place, name: 'Haverhill') }
  let(:destination) { FactoryGirl.create(:place, name: 'Newmarket') }
  let(:other_place) { FactoryGirl.create(:place, name: 'Somewhere Else') }
  
  let(:route) do
    FactoryGirl.create(:route, stops: [
      FactoryGirl.create(:stop),
      FactoryGirl.create(:stop, place: origin),
      FactoryGirl.create(:stop),
      FactoryGirl.create(:stop, place: destination)
    ])
  end
  
  let(:route2) do
    FactoryGirl.create(:route, stops: [
      FactoryGirl.create(:stop),
      FactoryGirl.create(:stop, place: destination),
      FactoryGirl.create(:stop),
      FactoryGirl.create(:stop, place: origin)
    ])
  end
  
  before do
    FactoryGirl.create_list(:journey, 2)
    FactoryGirl.create_list(:journey, 4, route: route, reversed: false)
    FactoryGirl.create_list(:journey, 3, route: route, reversed: true)
    FactoryGirl.create_list(:journey, 3, route: route2, reversed: false)
  end

  it 'renders a template' do
    expect(get :index).to render_template(:index)
  end
  
  it 'gets journeys from and to' do
    get :index, from: origin, to: destination
    
    expect(assigns(:journeys).count).to eq(4)
  end
  
  it 'gets reversed journeys' do
    get :index, from: destination, to: origin
    
    expect(assigns(:journeys).count).to eq(6)
  end
  
  it 'returns nothing if a origin does not exist' do
    get :index, from: destination, to: other_place
    
    expect(assigns(:journeys).count).to eq(0)
  end
  
  it 'suggests journeys' do
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
    
    get 'suggested', from: origin.slug
    
    expect(assigns(:places).count).to eq(5)
  end
  
end
