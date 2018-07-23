class AddPickupLandmarkAndDropoffLandmarkToBookings < ActiveRecord::Migration[4.2]
  def change
    add_reference :bookings, :pickup_landmark, index: true
    add_reference :bookings, :dropoff_landmark, index: true
  end
end
