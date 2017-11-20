FactoryGirl.define do
  factory(:booking) do
    dropoff_stop factory: :stop
    journey { FactoryGirl.create(:journey, supplier: supplier) }
    passenger
    phone_number nil
    pickup_stop factory: :stop
    state nil
    pickup_landmark { FactoryGirl.create(:landmark) }
    dropoff_landmark { FactoryGirl.create(:landmark) }
    
    trait(:booked) do
      state 'booked'
    end
    
    transient do
      supplier { FactoryGirl.create(:supplier) }
    end
    
    trait(:with_return_journey) do
      return_journey { FactoryGirl.create(:journey, supplier: supplier) }
    end
  end
end
