require 'rails_helper'

RSpec.describe Admin::PricingRulesController, type: :controller do
  login_supplier(true)
  
  describe 'GET new' do
    
    it 'initializes a rule' do
      get :new
      expect(assigns(:pricing_rule)).to be_a(PricingRule)
    end
    
  end
  
  describe 'POST create' do
    
    it 'creates a rule' do
      post :create, {
        pricing_rule: {
          name: 'Something',
          rule_type: :per_mile,
          per_mile: 35,
          child_multiplier: 0.75,
          return_multiplier: 2,
          allow_concessions: false
        }
      }
      
      expect(PricingRule.count).to eq(1)
      rule = PricingRule.first
      expect(rule.name).to eq('Something')
      expect(rule.rule_type).to eq('per_mile')
      expect(rule.per_mile).to eq(35)
      expect(rule.child_multiplier).to eq(0.75)
      expect(rule.return_multiplier).to eq(2.0)
      expect(rule.allow_concessions).to eq(false)
    end
    
    it 'creates a rule with stages' do
      post :create, {
        pricing_rule: {
          name: 'Something',
          rule_type: :staged,
          stages: {
            '15' => '5',
            '20' => '7'
          }.to_json,
          child_multiplier: 0.75,
          return_multiplier: 2,
          allow_concessions: false
        }
      }
      
      rule = PricingRule.first
      expect(rule.rule_type).to eq('staged')
      expect(rule.stages).to eq({
        '15' => '5',
        '20' => '7'
      })
    end
    
  end
  
  describe 'GET index' do
    
    let(:pricing_rules) { FactoryBot.create_list(:pricing_rule, 5) }
    
    it 'gets all rules' do
      get :index
      expect(assigns(:pricing_rules)).to match_array(pricing_rules)
    end
    
  end
  
end
