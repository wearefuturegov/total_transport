FactoryGirl.define do
  factory(:stop) do
    place
    route
    minutes_from_last_stop 20

    sequence(:position) { |n| n }
    
    transient { landmarks_count 1 }
    
    after(:build) { |stop| stop.class.skip_callback(:create, :after, :queue_minutes_from_last_stop) }
    
    factory(:stop_with_callback) do
      after(:create) { |stop| stop.send(:queue_minutes_from_last_stop) }
    end
    
    after(:build) do |stop, evaluator|
      stop.landmarks = FactoryGirl.create_list(:landmark, evaluator.landmarks_count, stop: nil)
    end
  end
end
