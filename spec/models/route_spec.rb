require 'rails_helper'

RSpec.describe Route, type: :model do
  
  let(:route) { FactoryBot.create(:route) }
  
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
