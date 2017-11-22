class AddPricingRuleToRoute < ActiveRecord::Migration
  def change
    add_column :routes, :pricing_rule, :json
  end
end
