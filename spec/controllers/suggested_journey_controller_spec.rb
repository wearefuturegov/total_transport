require 'rails_helper'

RSpec.describe SuggestedJourneyController, type: :controller do

  let(:passenger) { FactoryGirl.create(:passenger) }
  let(:route) { FactoryGirl.create(:route) }
  let(:booking) { FactoryGirl.create(:booking, passenger: passenger) }
  
  it 'displays a suggestion form' do
    get :new, { id: booking.id, route_id: route.id }, { current_passenger: passenger.session_token }
    expect(assigns(:route)).to eq(route)
    expect(assigns(:booking)).to eq(booking)
    expect(assigns(:page_title)).to eq('Suggest A New Time')
  end
  
  it 'creates a suggested journey' do
    start_time = '2017-01-01T09:00:00Z'
    description = 'Foo Bar'
    
    post :create, {
      id: booking.id,
      route_id: route.id,
      suggested_journey: {
        start_time: start_time,
        description: description
      }
    }, { current_passenger: passenger.session_token }
    
    expect(SuggestedJourney.count).to eq(1)
    suggested_journey = SuggestedJourney.last
    expect(suggested_journey.start_time).to eq(start_time)
    expect(suggested_journey.description).to eq(description)
  end
  
end
