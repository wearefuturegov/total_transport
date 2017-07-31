require 'rails_helper'

RSpec.describe Admin::BookingsController, type: :controller do
  login_supplier

  let(:booking) { FactoryGirl.create(:booking) }
  
  context '#show' do
    
    it 'shows a booking' do
      get :show, { id: booking.id }
      expect(assigns(:booking)).to eq(booking)
      expect(assigns(:back_path)).to eq(admin_journey_path(booking.journey_id))
    end
    
  end

end
