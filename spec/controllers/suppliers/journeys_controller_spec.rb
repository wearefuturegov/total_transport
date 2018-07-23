require 'rails_helper'

RSpec.describe Admin::JourneysController, type: :controller do
  login_supplier
  
  let(:journey) do
    FactoryBot.create(:journey,
      team: @supplier.team,
      outward_bookings: FactoryBot.create_list(:booking, 5)
    )
  end
  let(:route) { FactoryBot.create(:route) }
  
  context '#index' do
    
    context 'without a filter' do
      
      before do
        FactoryBot.create_list(:journey, 2)
        FactoryBot.create_list(:journey, 3, team: @supplier.team)
      end
      
      it 'gets all journeys for a team' do
        get :index, params: { filter: 'team' }
        expect(assigns(:journeys).count).to eq(3)
      end
      
      context 'as an admin' do
        login_supplier(true)

        it 'gets all journeys for an admin' do
          get :index
          expect(assigns(:journeys).count).to eq(5)
        end
      end
      
    end

    context 'filtering' do
      it 'filters by past or future' do
        FactoryBot.create_list(:journey, 2, start_time: DateTime.now - 4.days, team: @supplier.team)
        FactoryBot.create_list(:journey, 3, start_time: DateTime.now + 4.days, team: @supplier.team)
        get :index, params: { filterrific: {
            past_or_future: 'future'
          }
        }
        expect(assigns(:journeys).count).to eq(3)
        get :index, params: { filterrific: {
            past_or_future: 'past'
          }
        }
        expect(assigns(:journeys).count).to eq(2)
      end
      
      it 'filters by booked and empty' do
        outward = FactoryBot.create_list(:journey, 2, team: @supplier.team)
        outward.each do |j|
          j.outward_bookings = FactoryBot.create_list(:booking, 2)
        end
        returns = FactoryBot.create_list(:journey, 5, team: @supplier.team)
        returns.each do |j|
          j.return_bookings = FactoryBot.create_list(:booking, 2)
        end
        FactoryBot.create_list(:journey, 3, team: @supplier.team, booked: false)
        get :index, params: { filterrific: {
            booked_or_empty: 'booked'
          }
        }
        expect(assigns(:journeys).to_a.count).to eq(7)
        get :index, params: { filterrific: {
            booked_or_empty: 'empty'
          }
        }
        expect(assigns(:journeys).to_a.count).to eq(3)
      end
      
    end
  end
  
  context '#new' do
    
    it 'renders a route chooser if route_id is nil' do
      get :new
      expect(response).to render_template('admin/journeys/new_choose_route')
      expect(assigns(:back_path)).to eq(admin_root_path)
    end
    
    it 'gets the correct route and initializes a journey when route_id is defined' do
      get :new, params: { route_id: route.id, reversed: false }
      expect(assigns(:route)).to eq(route)
      journey = assigns(:journey)
      expect(journey.route).to eq(route)
      expect(journey.team).to eq(@supplier.team)
      expect(journey.reversed).to eq(false)
    end

  end
  
  context '#create' do
    
    it 'creates a new journey' do
      start_time = DateTime.now + 4.days
      post :create, params: {
        journey: {
          start_time: start_time,
          seats: 4,
          team_id: @supplier.team.id,
          route_id: route.id,
          open_to_bookings: true,
          reversed: true
        }
      }
      expect(Journey.all.count).to eq(1)
      journey = Journey.last
      expect(journey.start_time.to_i).to eq(start_time.to_i)
      expect(journey.seats).to eq(4)
      expect(journey.team).to eq(@supplier.team)
      expect(journey.route).to eq(route)
      expect(journey.open_to_bookings).to eq(true)
      expect(journey.reversed).to eq(true)
    end
  
  end
  
  context '#edit' do
    
    it 'gets a journey' do
      get :edit, params: { id: journey.id }
      expect(assigns(:journey)).to eq(journey)
    end
        
  end
  
  context '#show' do
    
    it 'gets a journey' do
      get :show, params: { id: journey.id }
      expect(assigns(:journey)).to eq(journey)
    end
    
    it 'returns a csv' do
      get :show, params: { id: journey.id, format: :csv }
      expect(response.headers['Content-Type']).to eq('text/csv; charset=utf-8')
    end
        
  end
  
  context '#update' do
    
    it 'updates a journey' do
      put :update, params: {
        id: journey.id,
        journey: {
          seats: 5,
        }
      }
      journey.reload
      expect(journey.seats).to eq(5)
    end
        
  end
  
  context '#destroy' do
    
    it 'destroys a journey' do
      journey = FactoryBot.create(:journey, team: @supplier.team)
      expect {
        delete :destroy, params: { id: journey.id }
      }.to change(Journey, :count).by(-1)
    end
            
  end
  
  context '#send_message' do
    it 'sends a message to one passenger' do
      booking = journey.outward_bookings.last
      expect  {
        post :send_message, params: {
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
        post :send_message, params: {
          id: journey.id,
          to: 'all',
          notification_message: 'Hello!'
        }
      }.to change { FakeSMS.messages.count }.by(5)
    end
  end

end
