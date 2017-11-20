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

end
