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
        'booking' => {},
        'id' => booking,
        'route_id' => route
      }
    }
    let(:journey) { FactoryGirl.create(:journey) }
    
    it 'save_return_journey updates the correct things' do
      booking_params = {
        return_journey_id: journey.id
      }
      
      params['booking'] = booking_params
      params['step'] = :return_journey
      put :update, params, { current_passenger: passenger.session_token }
      
      booking.reload
      booking_params.each do |k,v|
        expect(booking.send(k.to_sym)).to eq(v)
      end
    end
    
    it 'save_requirements updates the correct things' do
      booking_params = {
        'number_of_passengers' => 2,
        'child_tickets' => 1,
        'older_bus_passes' => 0,
        'disabled_bus_passes' => 0,
        'scholar_bus_passes' => 0,
        'special_requirements' => 'Some text here'
      }
      params['booking'] = booking_params
      params['step'] = :requirements
      put :update, params, { current_passenger: passenger.session_token }
      
      booking.reload
      booking_params.each do |k,v|
        expect(booking.send(k.to_sym)).to eq(v)
      end
    end
    
    it 'save_pickup_location updates the correct things' do
      booking_params = {
        pickup_lat: 52.4323,
        pickup_lng: -1.4234,
        pickup_name: 'Somewhere'
      }
      
      params['booking'] = booking_params
      params['step'] = :pickup_location
      put :update, params, { current_passenger: passenger.session_token }
      
      booking.reload
      booking_params.each do |k,v|
        expect(booking.send(k.to_sym)).to eq(v)
      end
    end
    
    it 'save_dropoff_location updates the correct things' do
      booking_params = {
        dropoff_lat: 52.4323,
        dropoff_lng: -1.4234,
        dropoff_name: 'Somewhere'
      }
      
      params['booking'] = booking_params
      params['step'] = :dropoff_location
      put :update, params, { current_passenger: passenger.session_token }
      
      booking.reload
      booking_params.each do |k,v|
        expect(booking.send(k.to_sym)).to eq(v)
      end
    end
    
    it 'save_confirm updates the correct things' do
      booking_params = {
        passenger_name: 'Me',
        phone_number: '1234',
        payment_method: 'cash'
      }
      
      params['booking'] = booking_params
      params['step'] = :confirm
      put :update, params, { current_passenger: passenger.session_token }
      
      booking.reload
      booking_params.each do |k,v|
        expect(booking.send(k.to_sym)).to eq(v)
      end
    end
    
    it 'save_confirm sends an SMS' do
      booking_params = {
        passenger_name: 'Me',
        phone_number: '1234',
        payment_method: 'cash'
      }
      
      params['booking'] = booking_params
      params['step'] = :confirm
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
    
    context 'edit_return_journey' do
      before do
        booking.journey = FactoryGirl.create(:journey, start_time: DateTime.now)
        booking.save
      end
      
      let!(:journeys) { FactoryGirl.create_list(:journey, 3, route: route) }
      let!(:reversed_journeys) { FactoryGirl.create_list(:journey, 5, route: route, reversed: true) }
      
      it 'sets the right variables' do
        get :edit, {
          'step' => :return_journey,
          'route_id' => route,
          'id' => booking
        },
        {
          current_passenger: passenger.session_token
        }
                
        expect(assigns(:page_title)).to eq('Return Journey')
        expect(assigns(:back_path)).to eq(from_to_journeys_path(booking.pickup_stop.place, booking.dropoff_stop.place))
        expect(assigns(:journeys).values.flatten).to eq(reversed_journeys)
      end
      
      it 'sets journeys when the booking is reversed' do
        booking.pickup_stop = route.stops.last
        booking.dropoff_stop = route.stops.first
        booking.save

        get :edit, {
          'step' => :return_journey,
          'route_id' => route,
          'id' => booking
        },
        {
          current_passenger: passenger.session_token
        }
        
        expect(assigns(:journeys).values.flatten).to eq(journeys)
      end
    end
    
    context 'edit_requirements' do
      it 'sets the right variables' do
        get :edit, {
          'step' => :requirements,
          'route_id' => route,
          'id' => booking
        },
        {
          current_passenger: passenger.session_token
        }
        
        expect(assigns(:page_title)).to eq('Requirements')
        expect(assigns(:back_path)).to eq(from_to_journeys_path(booking.pickup_stop.place, booking.dropoff_stop.place))
      end
      
      it 'sets the right variables when a return journey is present' do
        booking.return_journey = FactoryGirl.create(:journey, reversed: true)
        booking.save
        
        get :edit, {
          'step' => :requirements,
          'route_id' => route,
          'id' => booking
        },
        {
          current_passenger: passenger.session_token
        }
        
        expect(assigns(:page_title)).to eq('Requirements')
        expect(assigns(:back_path)).to eq(edit_return_journey_route_booking_path(route, booking))
      end
    end
    
    it 'edit_pickup_location sets the right variables' do
      get :edit, {
        'step' => :pickup_location,
        'route_id' => route,
        'id' => booking
      },
      {
        current_passenger: passenger.session_token
      }
      
      expect(assigns(:page_title)).to eq('Choose Pick Up Point')
      expect(assigns(:back_path)).to eq(edit_requirements_route_booking_path(route, booking))
      expect(assigns(:stop)).to eq(booking.pickup_stop)
      expect(assigns(:map_type)).to eq('pickup')
    end
    
    it 'edit_dropoff_location sets the right variables' do
      get :edit, {
        'step' => :dropoff_location,
        'route_id' => route,
        'id' => booking
      },
      {
        current_passenger: passenger.session_token
      }
      
      expect(assigns(:page_title)).to eq('Choose Drop Off Point')
      expect(assigns(:back_path)).to eq(edit_pickup_location_route_booking_path(route, booking))
      expect(assigns(:stop)).to eq(booking.dropoff_stop)
      expect(assigns(:map_type)).to eq('dropoff')
    end
    
    it 'confirm sets the right variables' do
      get :edit, {
        'step' => :confirm,
        'route_id' => route,
        'id' => booking
      },
      {
        current_passenger: passenger.session_token
      }
      
      expect(assigns(:page_title)).to eq('Overview')
      expect(assigns(:back_path)).to eq(edit_dropoff_location_route_booking_path(route, booking))
    end
    
  end
end
