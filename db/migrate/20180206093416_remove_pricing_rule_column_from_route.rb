class RemovePricingRuleColumnFromRoute < ActiveRecord::Migration[4.2]
  def change
    remove_column :routes, :pricing_rule, :json
  end
end
