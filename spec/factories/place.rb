FactoryBot.define do
  factory :place do
    sequence(:name) { |n| "place_#{n}" }
    sequence(:latitude)  { |n| 51.729312451546 + (n / 10.0) }
    sequence(:longitude) { |n| 0.892810821533203 + (n / 10.0) }
  end
end
