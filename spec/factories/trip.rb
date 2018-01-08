FactoryBot.define do
  factory(:trip) do
    journey nil
    booking { FactoryBot.create(:booking) }
  end
end
