FactoryGirl.define do
  factory(:journey) do
    open_to_bookings true
    route
    sequence(:start_time) { |n| Date.tomorrow + n.hours  }
    supplier { FactoryGirl.create(:supplier) }
    vehicle { FactoryGirl.create(:vehicle) }
  end
end
