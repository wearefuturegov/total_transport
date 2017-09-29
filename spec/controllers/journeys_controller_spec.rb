require 'rails_helper'

RSpec.describe JourneysController, type: :controller do
  
  let(:origin) { FactoryGirl.create(:place, name: 'Haverhill') }
  let(:destination) { FactoryGirl.create(:place, name: 'Newmarket') }
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
  
end
