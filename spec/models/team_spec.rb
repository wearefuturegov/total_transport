require 'rails_helper'

RSpec.describe Team, type: :model do
  
  it 'allows a name to be specified' do
    team = FactoryBot.create(:team, name: 'My Team', suppliers: FactoryBot.create_list(:supplier, 5))
    expect(team.name).to eq('My Team')
  end
  
  it 'has a default name' do
    suppliers = FactoryBot.create_list(:supplier, 1, name: 'Brian')
    team = FactoryBot.create(:team,
      suppliers: suppliers
    )
    
    expect(team.name).to eq('Brian\'s Team')
  end
  
  it 'leaves name alone if there are no suppliers' do
    team = FactoryBot.create(:team, suppliers: [], name: nil)
    expect(team.name).to eq(nil)
  end
  
end
