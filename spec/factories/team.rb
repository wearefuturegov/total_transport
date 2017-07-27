FactoryGirl.define do
  factory(:team) do
    name nil
    transient { suppliers_count 1 }
    after(:create) do |team, evaluator|
      create_list(:supplier, evaluator.suppliers_count, team: team)
    end
  end
end
