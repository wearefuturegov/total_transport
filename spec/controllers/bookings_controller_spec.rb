require 'rails_helper'

RSpec.describe BookingsController, type: :controller do

  let(:passenger) { FactoryBot.create(:passenger) }
  let!(:route) { FactoryBot.create(:route, stops_count: 0) }
  let!(:stops) {
    [
      FactoryBot.create(:stop, position: 1, route: route, place: FactoryBot.create(:place, name: 'Newmarket')),
      FactoryBot.create(:stop, position: 2, route: route),
      FactoryBot.create(:stop, position: 3, route: route),
      FactoryBot.create(:stop, position: 4, route: route),
      FactoryBot.create(:stop, position: 5, route: route, place: FactoryBot.create(:place, name: 'Haverhill'))
    ]
  }
  
  let!(:journeys) {
    [
      FactoryBot.create(:journey, route: route, start_time: "#{Date.today + 1.day}T09:00:00", reversed: false ),
      FactoryBot.create(:journey, route: route, start_time: "#{Date.today + 2.day}T10:00:00", reversed: false ),
      FactoryBot.create(:journey, route: route, start_time: "#{Date.today + 2.day}T09:00:00", reversed: false ),
      FactoryBot.create(:journey, route: route, start_time: "#{Date.today + 3.day}T10:00:00", reversed: false )
    ]
  }
  
  let!(:return_journeys) {
    [
      FactoryBot.create(:journey, route: route, start_time: "#{Date.today + 1.day}T09:00:00", reversed: true ),
      FactoryBot.create(:journey, route: route, start_time: "#{Date.today + 2.day}T10:00:00", reversed: true ),
      FactoryBot.create(:journey, route: route, start_time: "#{Date.today + 2.day}T09:00:00", reversed: true ),
      FactoryBot.create(:journey, route: route, start_time: "#{Date.today + 3.day}T10:00:00", reversed: true )
    ]
  }
  
  let(:booking) {
    FactoryBot.create(:booking,
      passenger: passenger,
      pickup_stop_id: route.stops.first.id,
      dropoff_stop_id: route.stops.last.id
    )
  }
  
  describe 'POST create' do
    let(:params) {
      {
        route_id: route.id,
        booking: {
          pickup_stop_id: route.stops.first.id,
          dropoff_stop_id: route.stops.last.id,
          passenger_attributes: {
            name: 'Me',
            phone_number: '+441473760072',
            email: 'email@example.com'
          }
        }
      }
    }
    let!(:subject) { post :create, params: params }
    let(:booking) { Booking.first }
    
    it 'creates a booking' do
      expect(Booking.count).to eq(1)
            
      expect(booking.pickup_stop_id).to eq(route.stops.first.id)
      expect(booking.dropoff_stop_id).to eq(route.stops.last.id)
    end
    
    it 'creates a passenger' do
      expect(booking.passenger).to_not eq(nil)
      expect(booking.passenger.name).to eq(params[:booking][:passenger_attributes][:name])
      expect(booking.passenger.email).to eq(params[:booking][:passenger_attributes][:email])
      expect(booking.passenger.phone_number).to eq(params[:booking][:passenger_attributes][:phone_number])
    end
    
  end
  
  describe 'PUT update' do
    let(:booking) {
      FactoryBot.create(:booking,
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
          pickup_landmark_id: FactoryBot.create(:landmark).id,
          dropoff_landmark_id: FactoryBot.create(:landmark).id,
          passenger_name: 'Me',
          phone_number: '1234',
          email: 'email@example.com',
          payment_method: 'cash',
        },
        id: booking,
        route_id: route
      }
    }
    let(:journey) { FactoryBot.create(:journey) }
    
    context 'confirmation' do
      
      let(:booking) {
        FactoryBot.create(:booking,
          passenger: passenger,
          pickup_stop_id: route.stops.first.id,
          dropoff_stop_id: route.stops.first.id,
          phone_number: '1234'
        )
      }
      
      let(:params) {
        {
          id: booking,
          route_id: route,
          confirm: 'Submit'
        }
      }
      
      it 'sends an SMS' do
        expect {
          put :update, params: params
        }.to change { FakeSMS.messages.count }.by(1)
      end
      
    end
    
    context 'cancelling journeys' do
      
      let(:params) {
        {
          booking: {
            state: 'cancelled',
            cancellation_reason: 'Some reason'
          },
          id: booking,
          route_id: route
        }
      }
      let(:subject) { put :update, params: params }
      
      it 'cancels a booking' do
        subject
        booking.reload
        expect(booking.state).to eq('cancelled')
        expect(booking.cancellation_reason).to eq('Some reason')
      end
      
      it 'redirects to the cancelled path' do
        expect(subject).to render_template(:cancelled)
      end
      
      it 'runs the callbacks' do
        expect(Booking).to receive(:find).with(booking.id.to_s) {
          expect(booking).to receive(:cancel)
          booking
        }
        subject
      end
      
    end
    
  end
  
  describe 'GET edit' do
    
    it 'gets available journeys' do
      get :edit, params: { route_id: route, id: booking }
      available_journeys = assigns(:journeys)
      
      expect(available_journeys[Date.today + 1.day]).to match_array([journeys[0]])
      expect(available_journeys[Date.today + 2.day]).to match_array([journeys[1], journeys[2]])
      expect(available_journeys[Date.today + 3.day]).to match_array([journeys[3]])
    end
    
    it 'sets the correct back_path' do
      get :edit, params: { route_id: route, id: booking }
      expect(assigns(:back_path)).to eq("/journeys/#{booking.pickup_stop.place.slug}/#{booking.dropoff_stop.place.slug}")
    end
    
  end
  
  describe 'GET cancel' do
    
    let(:booking) { FactoryBot.create(:booking) }
    let(:subject) {
      get :cancel, params: { token: booking.token }
    }
    
    it 'gets the booking by token' do
      subject
      expect(assigns(:booking)).to eq(booking)
    end
    
  end
  
  describe 'GET return_journeys' do
        
    it 'gets return journeys for a given datetime' do
      get :return_journeys, xhr: true, params: { route_id: route, id: booking, start_time: "#{Date.today + 2.day}T09:30:00", format: :js }
      expect(assigns(:journeys).count).to eq(1)
    end
    
  end
  
  describe 'PUT send_missed_feedback' do
    
    it 'creates feedback' do
      put :send_missed_feedback, params: {
        booking: {
          state: 'missed',
          missed_feedback: 'Something',
          token: booking.token
        },
        id: booking
      }
      
      booking.reload
      expect(booking.state).to eq('missed')
      expect(booking.missed_feedback).to eq('Something')
    end
    
    it 'returns 401 if token is incorrect' do
      put :send_missed_feedback, params: {
        booking: {
          state: 'missed',
          missed_feedback: 'Something',
          token: 'dsfsdfdfdsfds'
        },
        id: booking
      }
      
      expect(response.code).to eq('401')
      expect(booking.state).to eq(nil)
      
      booking.reload

      expect(booking.missed_feedback).to eq(nil)
    end
    
  end
  
end
