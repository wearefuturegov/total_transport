require 'rails_helper'

RSpec.describe BookingsController, type: :controller do

  let(:passenger) { FactoryGirl.create(:passenger) }
  let(:route) { FactoryGirl.create(:route) }
  
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
      post :create, params, { current_passenger: passenger.session_token }
      
      expect(Booking.count).to eq(1)
      
      booking = Booking.first
      
      expect(booking.pickup_stop_id).to eq(route.stops.first.id)
      expect(booking.dropoff_stop_id).to eq(route.stops.last.id)
    end
    
  end
  
  describe 'PUT update' do
    let(:booking) {
      FactoryGirl.create(:booking,
        passenger: passenger,
        pickup_stop_id: route.stops.first.id,
        dropoff_stop_id: route.stops.first.id,
      )
    }
    let(:params) {
      {
        booking: {
          return_journey_id: journey.id,
          number_of_passengers: 2,
          child_tickets: 1,
          older_bus_passes: 0,
          disabled_bus_passes: 0,
          scholar_bus_passes: 0,
          special_requirements: 'Some text',
          pickup_landmark_id: FactoryGirl.create(:landmark).id,
          dropoff_landmark_id: FactoryGirl.create(:landmark).id,
          passenger_name: 'Me',
          phone_number: '1234',
          payment_method: 'cash'
        },
        id: booking,
        route_id: route
      }
    }
    let(:journey) { FactoryGirl.create(:journey) }
    
    it 'updates a booking' do
      put :update, params, { current_passenger: passenger.session_token }
      booking.reload
      params[:booking].each do |k,v|
        expect(booking.send(k.to_sym)).to eq(v)
      end
    end
    
    it 'sends an SMS' do
      expect {
        put :update, params, { current_passenger: passenger.session_token }
      }.to change { FakeSMS.messages.count }.by(1)
    end
  end
  
  describe 'GET edit' do
    let(:booking) {
      FactoryGirl.create(:booking,
        passenger: passenger,
        pickup_stop_id: route.stops.first.id,
        dropoff_stop_id: route.stops.first.id,
      )
    }
    
    let!(:journeys) {
      [
        FactoryGirl.create(:journey, route: route, start_time: "#{Date.today + 1.day}T09:00:00", reversed: false ),
        FactoryGirl.create(:journey, route: route, start_time: "#{Date.today + 2.day}T10:00:00", reversed: false ),
        FactoryGirl.create(:journey, route: route, start_time: "#{Date.today + 2.day}T09:00:00", reversed: false ),
        FactoryGirl.create(:journey, route: route, start_time: "#{Date.today + 3.day}T10:00:00", reversed: false )
      ]
    }
    
    it 'gets available journeys' do
      get :edit, route_id: route, id: booking
      expect(assigns(:journeys)).to eq({
        (Date.today + 1.day) => [
          journeys[0]
        ],
        (Date.today + 2.day) => [
          journeys[1],
          journeys[2]
        ],
        (Date.today + 3.day) => [
          journeys[3]
        ]
      })
    end
    
    it 'sets the correct back_path' do
      get :edit, route_id: route, id: booking
      expect(assigns(:back_path)).to eq("/journeys/#{booking.pickup_stop.place.slug}/#{booking.dropoff_stop.place.slug}")
    end
    
  end
end
