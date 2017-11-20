FactoryBot.define do
  factory(:booking) do
    dropoff_stop factory: :stop
    journey { FactoryBot.create(:journey, supplier: supplier) }
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
      supplier { FactoryBot.create(:supplier) }
    end
    
    trait(:with_return_journey) do
      return_journey { FactoryBot.create(:journey, supplier: supplier) }
    end
  end
end
