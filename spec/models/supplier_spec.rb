require 'rails_helper'

RSpec.describe Supplier, type: :model do
  it "should create a team on creation" do
    @supplier = create(:supplier, team: nil)
    expect(@supplier.team).to be_a(Team)
  end
end
