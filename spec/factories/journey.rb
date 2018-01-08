FactoryBot.define do
  factory(:journey) do
    open_to_bookings true
    route
    sequence(:start_time) { |n| Date.tomorrow + n.hours  }
    supplier { FactoryBot.create(:supplier) }
    vehicle { FactoryBot.create(:vehicle) }
  end
end
