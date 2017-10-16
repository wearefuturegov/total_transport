FactoryGirl.define do
  factory(:booking) do
    dropoff_stop factory: :stop
    journey
    passenger
    phone_number nil
    pickup_stop factory: :stop
    state nil
    pickup_landmark { FactoryGirl.create(:landmark) }
    dropoff_landmark { FactoryGirl.create(:landmark) }
  end
end
