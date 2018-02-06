class PricingRule < ActiveRecord::Base
  has_many :routes
  
  enum rule_type: [:per_mile, :staged]
  
  Stage = Struct.new(:from, :to, :price)
  
  def stages
    from = 0
    read_attribute(:stages).map do |k,v|
      stage = Stage.new(from.to_i, k.to_i, v.to_i)
      from = k
      stage
    end
  end
  
end
