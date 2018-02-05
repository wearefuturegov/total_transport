class CreatePricingRules < ActiveRecord::Migration
  def change
    create_table :pricing_rules do |t|
      t.string :name
      t.integer :rule_type
      t.float :per_mile, default: 0.0
      t.jsonb :stages, null: false, default: {}
      t.float :child_multiplier, default: 0.5
      t.float :return_multiplier, default: 1.5
      t.boolean :allow_concessions, default: true
      
      t.timestamps null: false
    end
    
    add_reference :routes, :pricing_rule, index: true
  end
end
