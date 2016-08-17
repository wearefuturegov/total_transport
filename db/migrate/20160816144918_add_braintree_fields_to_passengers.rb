class AddBraintreeFieldsToPassengers < ActiveRecord::Migration
  def change
    add_column :passengers, :braintree_id, :string
    add_column :passengers, :braintree_token, :string
  end
end
