class AddAttributeToBooking < ActiveRecord::Migration
  def change
    add_column :bookings, :passenger_name, :string
  end
end
