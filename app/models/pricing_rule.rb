class PricingRule < ActiveRecord::Base
  has_many :routes
  
  enum rule_type: [:per_mile, :staged]
  
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
  
end
