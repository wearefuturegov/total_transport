FactoryGirl.define do
  factory(:generated_journey) do
    start_time DateTime.now
    route { FactoryGirl.create(:route) }
    bookings { FactoryGirl.create_list(:booking, 5) }
  end
end
