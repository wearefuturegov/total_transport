require 'rails_helper'

RSpec.describe Admin::PromoCodesController, type: :controller do
  login_supplier(true)
  
  context '#index' do
    
    let(:promo_codes) { FactoryBot.create_list(:promo_code, 5) }
    let!(:subject) { get :index }
    
    it 'lists all the promo codes' do
      expect(assigns(:promo_codes)).to eq(promo_codes)
    end
    
    it 'initializes a new promo code' do
      expect(assigns(:promo_code)).to be_a(PromoCode)
    end
    
  end
  
  context '#create' do
    
    let(:subject) {
      post :create, params: {
        promo_code: {
          price_deduction: 3
        }
      }
    }
    
    it 'creates a promo code' do
      subject
      expect(assigns(:promo_code).price_deduction).to eq(3)
      expect(assigns(:promo_code).code).to_not be_nil
      expect(PromoCode.count).to eq(1)
    end
    
    it 'redirects' do
      expect(subject).to redirect_to(admin_promo_codes_path)
    end
    
  end
  
  context '#destroy' do
    
    let!(:promo_code) { FactoryBot.create(:promo_code) }
    let(:subject) {
      delete :destroy, params: {
        id: promo_code.id
      }
    }
    
    it 'creates a promo code' do
      expect { subject }.to change(PromoCode, :count).by(-1)
    end
    
    it 'redirects' do
      expect(subject).to redirect_to(admin_promo_codes_path)
    end
    
  end
  

end
