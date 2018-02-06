class RemovePricingRuleColumnFromRoute < ActiveRecord::Migration
  def change
    remove_column :routes, :pricing_rule, :json
  end
end
