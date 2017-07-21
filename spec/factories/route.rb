FactoryGirl.define do
  factory(:route) do
    transient { stops_count 5 }
    after(:create) do |route, evaluator|
      create_list(:stop, evaluator.stops_count, route: route) unless evaluator.stops.count > 0
    end
  end
end
