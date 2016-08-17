FactoryGirl.define do
  factory(:journey) do
    open_to_bookings true
    route
    start_time "2016-08-10T17:00 UTC"
    supplier
    vehicle
  end
end
