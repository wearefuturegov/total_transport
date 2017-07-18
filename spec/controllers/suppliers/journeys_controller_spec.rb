require 'rails_helper'

RSpec.describe Admin::JourneysController, type: :controller do
  login_supplier
  
  let(:journey) do
    FactoryGirl.create(:journey,
      supplier: @supplier,
      outward_bookings: FactoryGirl.create_list(:booking, 5)
    )
  end
  
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
