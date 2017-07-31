FactoryGirl.define do
  factory :promo_code do
    price_deduction "9.99"
    code SecretSanta.create_code
  end
end
