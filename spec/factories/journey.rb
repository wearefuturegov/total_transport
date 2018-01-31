FactoryBot.define do
  factory(:journey) do
    open_to_bookings true
    route
    sequence(:start_time) { |n| Date.tomorrow + n.hours  }
    team { FactoryBot.create(:team) }
    seats 5
  end
end
