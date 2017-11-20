require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  
  let(:passenger) { FactoryBot.create(:passenger) }
  
  it 'sets the correct vars' do
    get :new, { passenger_id: passenger.id }
    expect(assigns(:passenger)).to eq(passenger)
    expect(assigns(:back_path)).to eq(new_passenger_path)
  end
  
  it 'logs a passenger in' do
    post :create, { passenger_id: passenger.id, verification_code: passenger.verification_code }
    expect(session[:current_passenger]).to eq(passenger.session_token)
    expect(response.redirect?).to eq(true)
    expect(response).to redirect_to(root_path)
  end
  
  it 'returns an error if the code is wrong' do
    post :create, { passenger_id: passenger.id, verification_code: '1234' }
    expect(session[:current_passenger]).to eq(nil)
    expect(assigns(:flash_alert)).to eq('That verification code was incorrect. Please try again.')
  end
  
  it 'logs a passenger out' do
    delete :destroy, {}, { current_passenger: passenger.session_token }
    expect(session[:current_passenger]).to eq(nil)
    expect(response).to redirect_to(root_path)
  end
  
end
