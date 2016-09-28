class CreatePaymentMethods < ActiveRecord::Migration
  def change
    create_table :payment_methods do |t|
      t.string :name
      t.references :passenger, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
