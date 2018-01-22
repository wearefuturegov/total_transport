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
  
  context 'flipped_geometery' do
    
    it 'returns an empty array by default' do
      expect(route.flipped_geometery).to eq([])
    end
    
    it 'flips the geometry' do
      route.geometry = [[52.2223, -1.6759]]
      expect(route.flipped_geometery).to eq([[-1.6759, 52.2223]])
    end
    
  end
  
end
