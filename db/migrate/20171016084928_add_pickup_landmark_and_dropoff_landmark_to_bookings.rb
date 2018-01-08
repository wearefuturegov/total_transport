class AddPickupLandmarkAndDropoffLandmarkToBookings < ActiveRecord::Migration
  def change
    add_reference :bookings, :pickup_landmark, index: true
    add_reference :bookings, :dropoff_landmark, index: true
  end
end
