require 'rails_helper'

RSpec.describe Route, type: :model do
  let(:route) { FactoryBot.create(:route) }
  
  context 'pricing_rule' do
    
    it 'has a pricing rule' do
      route.pricing_rule = {
        child_single_price: 0,
        child_return_price: 0
      }
      route.save
      expect(route.pricing_rule).to eq({
        'child_single_price' => 0,
        'child_return_price' => 0
      })
    end
    
    it 'returns an empty hash by default' do
      expect(route.pricing_rule).to eq({})
    end
    
  end
  
  context 'allow_concessions' do
    
    it 'returns true by default' do
      expect(route.allow_concessions).to eq(true)
    end
    
  end
  
end
