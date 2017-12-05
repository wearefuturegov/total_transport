require 'rails_helper'

RSpec.describe Admin::BookingsController, type: :controller do
  login_supplier(true)

  let(:booking) { FactoryBot.create(:booking, :with_return_journey) }
  
  context '#show' do
    
    it 'shows a booking' do
      get :show, { id: booking.id }
      expect(assigns(:booking)).to eq(booking)
      expect(assigns(:back_path)).to eq(admin_journey_path(booking.journey_id))
    end
    
    it 'gets the outward trip' do
      get :show, { id: booking.id, journey_id: booking.journey_id }
      expect(assigns(:trip).journey).to eq(booking.journey)
    end
    
    it 'gets the return trip' do
      get :show, { id: booking.id, journey_id: booking.return_journey_id  }
      expect(assigns(:trip).journey).to eq(booking.return_journey)
    end
    
  end
  
  
  context '#index' do
    
    let!(:cancelled_bookings) { FactoryBot.create_list(:booking, 3, :with_return_journey, state: 'cancelled')  }
    let!(:booked_bookings) { FactoryBot.create_list(:booking, 5, :with_return_journey, state: 'booked')  }
    
    it 'gets all booked bookings' do
      get :index
      
      expect(assigns(:bookings)).to eq(booked_bookings)
    end
    
    it 'filters by route' do
      route = FactoryBot.create(:route)
      journey = FactoryBot.create(:journey, route: route)
      booked_bookings[0].update_attributes(journey: journey)
      booked_bookings[1].update_attributes(journey: journey)

      get :index, filterrific: { route: route.id, state: 'booked' }
      
      expect(assigns(:bookings)).to eq([booked_bookings[0], booked_bookings[1]])
    end
    
    it 'filters by date from' do
      journey = FactoryBot.create(:journey, start_time: DateTime.now + 2.days)
      booked_bookings[3].update_attributes(journey: journey)
      booked_bookings[4].update_attributes(journey: journey)

      get :index, filterrific: { date_from: Date.today + 2.days, state: 'booked' }

      expect(assigns(:bookings)).to eq([booked_bookings[3], booked_bookings[4]])
    end
    
    it 'filters by date to' do
      journey = FactoryBot.create(:journey, start_time: DateTime.now - 2.days)
      booked_bookings[3].update_attributes(journey: journey)
      booked_bookings[4].update_attributes(journey: journey)

      get :index, filterrific: { date_to: Date.today - 2.days, state: 'booked' }

      expect(assigns(:bookings)).to eq([booked_bookings[3], booked_bookings[4]])
    end
    
    it 'filters by state' do
      get :index, filterrific: { state: 'cancelled' }
      expect(assigns(:bookings)).to eq(cancelled_bookings)
    end
    
    it 'filters by team' do
      supplier = FactoryBot.create(:supplier)
      journey = FactoryBot.create(:journey, supplier: supplier)
      booked_bookings[4].update_attributes(journey: journey)
      
      get :index, filterrific: { team: supplier.team }
      expect(assigns(:bookings)).to eq([ booked_bookings[4] ])
    end
    
    it 'generates a CSV' do
      get :index, format: :csv
      
      csv = CSV.parse(response.body)
      
      expect(csv[0]).to eq([
        'Name',
        'Phone Number',
        'Pickup Place',
        'Dropoff Place',
        'Pickup Landmark',
        'Dropoff Landmark',
        'Pickup Time',
        'Dropoff Time',
        'Price'
      ])
      
      booked_bookings.each_with_index do |b, i|
        expect(csv[i + 1]).to eq(b.csv_row)
      end
    end
    
  end

end
