class PricingRule < ApplicationRecord
  has_many :routes
  
  enum rule_type: [:per_mile, :staged]
  enum child_fare_rule: [:multiplier, :flat_rate]
  
  Stage = Struct.new(:from, :to, :price)
  
  def stages
    from = 0
    read_attribute(:stages).map do |k,v|
      stage = Stage.new(from.to_i, k.to_i, v.to_f)
      from = k
      stage
    end
  end
  
  def get_single_price(distance)
    if per_mile?
      (distance * per_mile) / 100
    elsif staged?
      (stages.find { |s| distance.between?(s.from, s.to) } || stages.last).price
    end
  end
  
  def get_child_price(distance)
    if flat_rate?
      child_flat_rate
    elsif multiplier?
      get_single_price(distance) * child_multiplier
    end
  end
  
end
