FactoryGirl.define do
  factory :place do
    sequence(:name) { |n| "place_#{n}" }
    latitude 51.729312451546
    longitude 0.892810821533203
  end
end
