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
      expect(rule.stages.count).to eq(2)
      expect(rule.stages[0].from).to eq(0)
      expect(rule.stages[0].to).to eq(15)
      expect(rule.stages[0].price).to eq(5)
      expect(rule.stages[1].from).to eq(15)
      expect(rule.stages[1].to).to eq(20)
      expect(rule.stages[1].price).to eq(7)
    end
    
    it 'creates a rule with a child flat rate' do
      post :create, {
        pricing_rule: {
          name: 'Something',
          rule_type: :per_mile,
          per_mile: 35,
          child_fare_rule: :flat_rate,
          child_flat_rate: 1,
          return_multiplier: 2,
          allow_concessions: false
        }
      }
      
      rule = PricingRule.first
      expect(rule.child_fare_rule).to eq('flat_rate')
      expect(rule.child_flat_rate).to eq(1)
    end
    
  end
  
  describe 'GET index' do
    
    let(:pricing_rules) { FactoryBot.create_list(:pricing_rule, 5) }
    
    it 'gets all rules' do
      get :index
      expect(assigns(:pricing_rules)).to match_array(pricing_rules)
    end
    
  end
  
  describe 'GET edit' do
    
    let(:pricing_rule) { FactoryBot.create(:pricing_rule) }
    
    it 'gets a rule' do
      get :edit, id: pricing_rule
      expect(assigns(:pricing_rule)).to eq(pricing_rule)
    end
    
  end
  
  describe 'PUT update' do
    
    let(:pricing_rule) { FactoryBot.create(:pricing_rule) }
    
    it 'updates a rule' do
      put :update, {
        id: pricing_rule,
        pricing_rule: {
          name: 'Something',
          rule_type: :per_mile,
          per_mile: 35,
          child_multiplier: 0.75,
          return_multiplier: 2,
          allow_concessions: false
        }
      }
      
      pricing_rule.reload
      expect(pricing_rule.name).to eq('Something')
      expect(pricing_rule.rule_type).to eq('per_mile')
      expect(pricing_rule.per_mile).to eq(35)
      expect(pricing_rule.child_multiplier).to eq(0.75)
      expect(pricing_rule.return_multiplier).to eq(2.0)
      expect(pricing_rule.allow_concessions).to eq(false)
    end
    
    it 'updates a rule with stages' do
      put :update, {
        id: pricing_rule,
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
      
      pricing_rule.reload
      expect(pricing_rule.rule_type).to eq('staged')
      expect(pricing_rule.stages.count).to eq(2)
      expect(pricing_rule.stages[0].from).to eq(0)
      expect(pricing_rule.stages[0].to).to eq(15)
      expect(pricing_rule.stages[0].price).to eq(5)
      expect(pricing_rule.stages[1].from).to eq(15)
      expect(pricing_rule.stages[1].to).to eq(20)
      expect(pricing_rule.stages[1].price).to eq(7)
    end

  end
  
end
