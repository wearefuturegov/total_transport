class AddPricingRuleToRoute < ActiveRecord::Migration[4.2]
  def change
    add_column :routes, :pricing_rule, :json
  end
end
