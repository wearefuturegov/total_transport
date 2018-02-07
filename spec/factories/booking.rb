FactoryBot.define do
  factory(:booking) do
    dropoff_stop factory: :stop
    journey { FactoryBot.create(:journey, team: team) }
    passenger
    phone_number nil
    pickup_stop factory: :stop
    state nil
    pickup_landmark { FactoryBot.create(:landmark) }
    dropoff_landmark { FactoryBot.create(:landmark) }
    
    trait(:booked) do
      state 'booked'
    end
    
    transient do
      team { FactoryBot.create(:team) }
    end
    
    trait(:with_return_journey) do
      return_journey { FactoryBot.create(:journey, team: team) }
    end
  end
end
