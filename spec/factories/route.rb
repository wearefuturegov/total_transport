FactoryBot.define do
  factory(:route) do
    transient { stops_count 5 }
    pricing_rule { FactoryBot.create(:pricing_rule) }
    after(:create) do |route, evaluator|
      create_list(:stop, evaluator.stops_count, route: route) unless evaluator.stops.count > 0
    end
    
    after(:build) { |route| route.class.skip_callback(:save, :after, :queue_geometry) }

  end
end
