class CreateSupplierSuggestions < ActiveRecord::Migration
  def change
    create_table :supplier_suggestions do |t|
      t.references :supplier, index: true, foreign_key: true
      t.string :url
      t.text :description

      t.timestamps null: false
    end
  end
end
