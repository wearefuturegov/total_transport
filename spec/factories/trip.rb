FactoryGirl.define do
  factory(:trip) do
    journey nil
    booking { FactoryGirl.create(:booking) }
  end
end
