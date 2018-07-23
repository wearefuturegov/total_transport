class AddAttributeToBooking < ActiveRecord::Migration[4.2]
  def change
    add_column :bookings, :passenger_name, :string
  end
end
