class AddLocationNamesToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :pickup_name, :string
    add_column :bookings, :dropoff_name, :string
  end
end
