class RemovePickupAndDropoffLatLngs < ActiveRecord::Migration[4.2]
  def change
    remove_column :bookings, :pickup_lat, :double
    remove_column :bookings, :pickup_lng, :double
    remove_column :bookings, :dropoff_lat, :double
    remove_column :bookings, :dropoff_lng, :double
  end
end
