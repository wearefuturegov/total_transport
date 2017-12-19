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
  
  it 'runs the SetRouteGeometry job after creation', :que do
    route = FactoryBot.create(:route)
    Route.set_callback(:save, :after, :queue_geometry)
    expect {
      route.save
    }.to change {
      QueJob.where(job_class: 'SetRouteGeometry').count
    }.by(1)
  end
  
  context 'sub routes' do
    
    it 'can have a sub route' do
      sub_routes = FactoryBot.create_list(:route, 3)
      route = FactoryBot.create(:route, sub_routes: sub_routes)

      expect(route.sub_routes).to eq(sub_routes)
    end
    
    it 'won\'t let sub routes have sub routes' do
      route = FactoryBot.create(:route)
      FactoryBot.create(:route, sub_routes: [route])
      route.sub_routes = FactoryBot.create_list(:route, 3)
      
      expect(route.valid?).to eq(false)
      expect(route.errors[:sub_routes]).to eq(['cannot be added for a sub route'])
    end
    
    
  end
  
end
