require 'rails_helper'

RSpec.describe SuggestedEditToStopController, type: :controller do

  let(:passenger) { FactoryBot.create(:passenger) }
  let(:route) { FactoryBot.create(:route) }
  let(:booking) { FactoryBot.create(:booking, passenger: passenger) }
  let(:stop) { route.stops.first }
  
  it 'displays a suggestion form' do
    get :new, { id: booking.id, route_id: route.id, stop_id: stop.id }, { current_passenger: passenger.session_token }
    expect(assigns(:route)).to eq(route)
    expect(assigns(:booking)).to eq(booking)
    expect(assigns(:stop)).to eq(stop)
    expect(assigns(:page_title)).to eq('Suggest A Stop Area Edit')
  end
  
  it 'creates a suggested journey' do
    description = 'Foo Bar'
    
    post :create, {
      id: booking.id,
      route_id: route.id,
      stop_id: stop.id,
      suggested_edit_to_stop: {
        description: description
      }
    }, { current_passenger: passenger.session_token }
    
    expect(SuggestedEditToStop.count).to eq(1)
    suggested_journey = SuggestedEditToStop.last
    expect(suggested_journey.description).to eq(description)
  end
    
end
