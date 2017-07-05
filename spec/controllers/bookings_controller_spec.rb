require 'rails_helper'

RSpec.describe BookingsController, type: :controller do

  let(:passenger) { FactoryGirl.create(:passenger) }
  let(:route) { FactoryGirl.create(:route) }
  
  describe 'GET new' do
    
    it 'sets the correct vars' do
      get :new, { route_id: route.id }, { current_passenger: passenger.id }
      
      expect(assigns(:page_title)).to eq('Choose Your Pick Up Area')
      expect(assigns(:back_path)).to eq(routes_path)
      expect(assigns(:top_sec)).to eq('Choose your pick up and drop off areas.')
      expect(assigns(:booking)).to be_a(Booking)
      expect(assigns(:booking).passenger).to eq(passenger)
      expect(assigns(:stops).first.name).to eq("stop_1")
    end
    
    it 'shows the normal order of stops' do
      get :new, { route_id: route.id }, { current_passenger: passenger.id }
      expect(assigns(:stops).first).to eq(route.stops.first)
      expect(assigns(:stops).last).to eq(route.stops.last)
    end
    
    it 'reverses the order of stops' do
      get :new, { route_id: route.id, reversed: 'true' }, { current_passenger: passenger.id }
      expect(assigns(:stops).first).to eq(route.stops.last)
      expect(assigns(:stops).last).to eq(route.stops.first)
    end
    
  end
  
  describe 'POST create' do
    let(:params) {
      {
        route_id: route.id,
        booking: {
          pickup_stop_id: route.stops.first.id,
          dropoff_stop_id: route.stops.last.id,
        }
      }
    }
    
    it 'creates a booking' do
      post :create, params, { current_passenger: passenger.id }
      
      expect(Booking.count).to eq(1)
      
      booking = Booking.first
      
      expect(booking.passenger).to eq(passenger)
      expect(booking.pickup_stop_id).to eq(route.stops.first.id)
      expect(booking.dropoff_stop_id).to eq(route.stops.last.id)
    end
    
  end

end
