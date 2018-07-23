class RemovePaymentMethods < ActiveRecord::Migration[4.2]
  def change
    remove_column :bookings, :payment_method_id, :integer
    drop_table :payment_methods do |t|
      t.string :name
      t.references :passenger, index: true, foreign_key: true

      t.timestamps null: false
    end
    add_column :bookings, :payment_method, :string, default: 'cash'
  end
end
