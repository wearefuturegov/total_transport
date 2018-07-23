class CreateSuggestedRoutes < ActiveRecord::Migration[4.2]
  def change
    create_table :suggested_routes do |t|
      t.references :passenger, index: true, foreign_key: true
      t.text :description

      t.timestamps null: false
    end
  end
end
