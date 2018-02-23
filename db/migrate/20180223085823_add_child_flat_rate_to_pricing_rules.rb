class AddChildFlatRateToPricingRules < ActiveRecord::Migration
  def change
    add_column :pricing_rules, :child_fare_rule, :integer, default: 0
    add_column :pricing_rules, :child_flat_rate, :float
  end
end
