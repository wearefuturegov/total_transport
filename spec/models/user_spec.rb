require 'rails_helper'

RSpec.describe User, type: :model do
  it "should create a team on creation" do
    @user = User.create!(email: 'test@test.com', password: 'password', password_confirmation: 'password')
    expect(@user.team).to be_a(Team)
  end
end
