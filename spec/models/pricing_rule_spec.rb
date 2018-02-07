require 'rails_helper'

RSpec.describe PricingRule, type: :model do
  
  describe '#stages' do
  
    it 'returns stages as an array of structs' do
      rule = FactoryBot.create(:pricing_rule, stages: {
        '5' => '2',
        '10' => '4',
        '15' => '6'
      })
      
      expect(rule.stages.count).to eq(3)
      expect(rule.stages[0].from).to eq(0)
      expect(rule.stages[0].to).to eq(5)
      expect(rule.stages[0].price).to eq(2)
    end
    
  end
  
  describe '#get_single_price' do
    
    context 'with per mile' do
      
      let(:rule) { FactoryBot.create(:pricing_rule, rule_type: :per_mile, per_mile: 40) }
      
      it 'returns the price' do
        expect(rule.get_single_price(5)).to eq(2)
      end
      
    end
    
    context 'with staged pricing' do
      
      let(:rule) do
        FactoryBot.create(:pricing_rule, rule_type: :staged, stages: {
          '5' => '2',
          '10' => '4',
          '15' => '6'
        })
      end
      
      it 'returns the correct price for between 0 and 5' do
        expect(rule.get_single_price(3)).to eq(2)
      end
      
      it 'returns the correct price for between 5 and 10' do
        expect(rule.get_single_price(7)).to eq(4)
      end
      
      it 'returns the correct price for between 10 and 15' do
        expect(rule.get_single_price(12)).to eq(6)
      end
      
      it 'returns the correct price for over 15' do
        expect(rule.get_single_price(17)).to eq(6)
      end
      
    end
    
  end
  
  
  
end
