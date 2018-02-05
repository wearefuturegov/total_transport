class PricingRule < ActiveRecord::Base
  has_many :routes
  
  enum rule_type: [:per_mile, :staged]
end
