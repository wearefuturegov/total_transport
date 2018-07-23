class AddPassengerToBookings < ActiveRecord::Migration[4.2]
  def change
    add_reference :bookings, :passenger, index: true, foreign_key: true
  end
end
