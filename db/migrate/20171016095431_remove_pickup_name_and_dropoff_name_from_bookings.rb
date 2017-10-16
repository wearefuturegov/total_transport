class RemovePickupNameAndDropoffNameFromBookings < ActiveRecord::Migration
  def change
    remove_column :bookings, :pickup_name, :string
    remove_column :bookings, :dropoff_name, :string
  end
end
