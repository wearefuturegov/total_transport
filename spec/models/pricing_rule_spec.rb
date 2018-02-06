require 'rails_helper'

RSpec.describe PricingRule, type: :model do
  
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
