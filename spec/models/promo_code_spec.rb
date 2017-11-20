require 'rails_helper'

RSpec.describe PromoCode, type: :model do
  
  let(:promo_code) { FactoryBot.create(:promo_code) }
  
  it 'creates a code' do
    expect(SecretSanta).to receive(:create_code) { 'sekritc0d3' }
    promo_code = FactoryBot.create(:promo_code)
    expect(promo_code.code).to eq('sekritc0d3')
  end
  
  it 'finds a promo code by code' do
    code = promo_code.code
    expect(PromoCode.find_by_code(code)).to eq(promo_code)
  end
  
  context '#used?' do
    
    it 'returns true if a booking is present' do
      promo_code.booking = FactoryBot.create(:booking)
      expect(promo_code.used?).to eq(true)
    end
    
    it 'returns false if a booking is not present' do
      expect(promo_code.used?).to eq(false)
    end
    
  end
  
  context '#available?' do
    
    it 'returns true if a booking is not present' do
      expect(promo_code.available?).to eq(true)
    end
    
    it 'returns false if a booking is present' do
      promo_code.booking = FactoryBot.create(:booking)
      expect(promo_code.available?).to eq(false)
    end
    
  end
  
end
