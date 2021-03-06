require 'rails_helper'

RSpec.describe Route, type: :model do
  let(:route) { FactoryBot.create(:route) }
  
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
  
  context 'name' do
    
    it 'allows a name to be set' do
      route.name = 'Cool Route'
      route.save
      expect(route.name).to eq('Cool Route')
    end
    
    it 'returns a default' do
      expect(route.name).to eq("Route #{route.id}: #{route.stops.first.name} - #{route.stops.last.name}")
    end
    
  end
  
  it 'saves all subroutes' do
    route.name = 'New Name'
    route.pricing_rule = FactoryBot.create(:pricing_rule)
    route.sub_routes = FactoryBot.create_list(:route, 5, name: 'Old Name', pricing_rule: nil, route: nil)
    route.save
    route.reload
    
    expect(route.sub_routes.pluck(:name).uniq).to eq(['New Name'])
    expect(route.sub_routes.pluck(:pricing_rule_id).uniq).to eq([route.pricing_rule.id])
  end
  
  describe 'id_with_subroutes' do
    
    context 'with subroutes' do
      
      let(:sub_routes) { FactoryBot.create_list(:route, 7) }
      
      before do
        route.sub_routes = sub_routes
        route.save
        route.reload
      end
      
      it 'gets the right IDs' do
        expect(Route.id_with_subroutes(route.id).count).to eq(8)
        expect(Route.id_with_subroutes(route.id)).to match_array(sub_routes.collect(&:id).push(route.id))
      end
      
    end
    
    it 'returns one id' do
      expect(Route.id_with_subroutes(route.id).count).to eq(1)
      expect(Route.id_with_subroutes(route.id)).to match_array([route.id])
    end
    
  end
  
  it 'gets ids for route and subroutes' do
    route.sub_routes = FactoryBot.create_list(:route, 7)
    route.save
    route.reload
    
    
  end
  
end
