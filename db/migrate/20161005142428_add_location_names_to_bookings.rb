class AddLocationNamesToBookings < ActiveRecord::Migration[4.2]
  def change
    add_column :bookings, :pickup_name, :string
    add_column :bookings, :dropoff_name, :string
  end
end
