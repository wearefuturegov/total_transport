require 'rails_helper'

RSpec.describe Admin::JourneysController, type: :controller do
  login_supplier
  
  let(:journey) do
    FactoryGirl.create(:journey,
      supplier: @supplier,
      outward_bookings: FactoryGirl.create_list(:booking, 5)
    )
  end
  let(:route) { FactoryGirl.create(:route) }
  
  context '#index' do
    it 'gets all journeys for a supplier' do
      FactoryGirl.create_list(:journey, 10, supplier: @supplier)
      get :index
      expect(assigns(:journeys).count).to eq(10)
    end
    
    it 'gets all journeys for a team' do
      FactoryGirl.create_list(:journey, 3)
      FactoryGirl.create_list(:journey, 5, supplier: @supplier)
      FactoryGirl.create_list(:journey, 4, supplier: FactoryGirl.create(:supplier, team: @supplier.team))
      get :index, { filter: 'team' }
      expect(assigns(:journeys).count).to eq(9)
    end
    
    it 'filters by past or future' do
      FactoryGirl.create_list(:journey, 2, start_time: DateTime.now - 4.days, supplier: @supplier)
      FactoryGirl.create_list(:journey, 3, start_time: DateTime.now + 4.days, supplier: @supplier)
      get :index, { filterrific: {
          past_or_future: 'future'
        }
      }
      expect(assigns(:journeys).count).to eq(3)
      get :index, { filterrific: {
          past_or_future: 'past'
        }
      }
      expect(assigns(:journeys).count).to eq(2)
    end
    
    it 'filters by booked and empty' do
      FactoryGirl.create_list(:journey, 2, outward_bookings: FactoryGirl.create_list(:booking, 4), supplier: @supplier, booked: true)
      FactoryGirl.create_list(:journey, 5, return_bookings: FactoryGirl.create_list(:booking, 2), supplier: @supplier, booked: true)
      FactoryGirl.create_list(:journey, 3, supplier: @supplier, booked: false)
      get :index, { filterrific: {
          booked_or_empty: 'booked'
        }
      }
      expect(assigns(:journeys).to_a.count).to eq(7)
      get :index, { filterrific: {
          booked_or_empty: 'empty'
        }
      }
      expect(assigns(:journeys).to_a.count).to eq(3)
    end
  end
  
  context '#new' do
    
    it 'renders a route chooser if route_id is nil' do
      get :new
      expect(response).to render_template('admin/journeys/new_choose_route')
      expect(assigns(:back_path)).to eq(admin_root_path)
    end
    
    it 'gets the correct route and initializes a journey when route_id is defined' do
      get :new, { route_id: route.id, reversed: false }
      expect(assigns(:route)).to eq(route)
      journey = assigns(:journey)
      expect(journey.route).to eq(route)
      expect(journey.supplier).to eq(@supplier)
      expect(journey.reversed).to eq(false)
    end

  end
  
  context '#create' do
    
    it 'creates a new journey' do
      start_time = DateTime.now + 4.days
      vehicle = FactoryGirl.create(:vehicle)
      post :create, {
        journey: {
          start_time: start_time,
          vehicle_id: vehicle.id,
          supplier_id: @supplier.id,
          route_id: route.id,
          open_to_bookings: true,
          reversed: true
        }
      }
      expect(Journey.all.count).to eq(1)
      journey = Journey.last
      expect(journey.start_time.to_i).to eq(start_time.to_i)
      expect(journey.vehicle).to eq(vehicle)
      expect(journey.supplier).to eq(@supplier)
      expect(journey.route).to eq(route)
      expect(journey.open_to_bookings).to eq(true)
      expect(journey.reversed).to eq(true)
    end
  
  end
  
  context '#edit' do
    
    it 'gets a journey' do
      get :edit, { id: journey.id }
      expect(assigns(:journey)).to eq(journey)
    end
        
  end
  
  context '#show' do
    
    it 'gets a journey' do
      get :show, { id: journey.id }
      expect(assigns(:journey)).to eq(journey)
    end
    
    it 'returns a csv' do
      get :show, { id: journey.id, format: :csv }
      expect(response.headers['Content-Type']).to eq('text/csv;charset=utf-8')
    end
        
  end
  
  context '#update' do
    
    it 'updates a journey' do
      vehicle = FactoryGirl.create(:vehicle, registration: 'ABC 1234')
      put :update, {
        id: journey.id,
        journey: {
          vehicle_id: vehicle.id,
        }
      }
      journey.reload
      expect(journey.vehicle.registration).to eq('ABC 1234')
    end
        
  end
  
  context '#destroy' do
    
    it 'destroys a journey' do
      journey = FactoryGirl.create(:journey, supplier: @supplier)
      expect {
        delete :destroy, { id: journey.id }
      }.to change(Journey, :count).by(-1)
    end
            
  end
  
  context '#send_message' do
    it 'sends a message to one passenger' do
      booking = journey.outward_bookings.last
      expect  {
        post :send_message, {
          id: journey.id,
          to: booking.id,
          notification_message: 'Hello!'
        }
      }.to change { FakeSMS.messages.count }.by(1)
      message = FakeSMS.messages.last
      expect(message[:to]).to eq(booking.phone_number)
      expect(message[:body]).to eq('Hello!')
    end
    
    it 'sends a message to all passengers' do
      expect  {
        post :send_message, {
          id: journey.id,
          to: 'all',
          notification_message: 'Hello!'
        }
      }.to change { FakeSMS.messages.count }.by(5)
    end
  end

end
