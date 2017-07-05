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
  
  describe 'GET edit' do
    let(:booking) {
      FactoryGirl.create(:booking,
        passenger: passenger,
        pickup_stop_id: route.stops.first.id,
        dropoff_stop_id: route.stops.first.id,
      )
    }
    
    it 'edit_requirements sets the right variables' do
      get :edit, {
        'step' => :requirements,
        'route_id' => route,
        'id' => booking
      },
      {
        current_passenger: passenger.id
      }
      
      expect(assigns(:page_title)).to eq('Choose Your Requirements')
      expect(assigns(:back_path)).to eq(new_route_booking_path(route))
    end
    
    context 'edit_journey' do
      let!(:journeys) { FactoryGirl.create_list(:journey, 3, route: route) }
      let!(:reversed_journeys) { FactoryGirl.create_list(:journey, 5, route: route, reversed: true) }
      
      it 'sets the right variables' do
        get :edit, {
          'step' => :journey,
          'route_id' => route,
          'id' => booking
        },
        {
          current_passenger: passenger.id
        }
        
        expect(assigns(:page_title)).to eq('Choose Your Time Of Travel')
        expect(assigns(:back_path)).to eq(edit_requirements_route_booking_path(route, booking))
        expect(assigns(:journeys).values.flatten).to eq(journeys)
      end
      
      it 'sets reversed journey when the booking is reversed' do
        booking = FactoryGirl.create(:booking, pickup_stop: route.stops.last, dropoff_stop: route.stops.first, passenger: passenger)

        get :edit, {
          'step' => :journey,
          'route_id' => route,
          'id' => booking
        },
        {
          current_passenger: passenger.id
        }
        
        expect(assigns(:journeys).values.flatten).to eq(reversed_journeys)
      end
    end
    
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
          current_passenger: passenger.id
        }
                
        expect(assigns(:page_title)).to eq('Pick Your Return Time')
        expect(assigns(:back_path)).to eq(edit_journey_route_booking_path(route, booking))
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
          current_passenger: passenger.id
        }
        
        expect(assigns(:journeys).values.flatten).to eq(journeys)
      end
    end
    
    it 'edit_pickup_location sets the right variables' do
      get :edit, {
        'step' => :pickup_location,
        'route_id' => route,
        'id' => booking
      },
      {
        current_passenger: passenger.id
      }
      
      expect(assigns(:page_title)).to eq('Choose Pick Up Point')
      expect(assigns(:back_path)).to eq(edit_return_journey_route_booking_path(route, booking))
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
        current_passenger: passenger.id
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
        current_passenger: passenger.id
      }
      
      expect(assigns(:page_title)).to eq('Overview')
      expect(assigns(:back_path)).to eq(edit_dropoff_location_route_booking_path(route, booking))
    end
    
  end
end
