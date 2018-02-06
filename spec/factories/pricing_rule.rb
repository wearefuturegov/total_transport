FactoryBot.define do
  factory :pricing_rule do
    rule_type :staged
    stages do {
      '5'  => '2',
      '10' => '4',
      '15' => '6',
      '20' => '8',
      '25' => '10',
      '30' => '12'
    }
    end
  end
end
