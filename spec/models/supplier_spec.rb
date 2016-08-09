require 'rails_helper'

RSpec.describe Supplier, type: :model do
  it "should create a team on creation" do
    @supplier = Supplier.create!(email: 'test@test.com', password: 'password', password_confirmation: '')
    expect(@supplier.team).to be_a(Team)
  end
end
