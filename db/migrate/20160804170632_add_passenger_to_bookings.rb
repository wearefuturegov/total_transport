class AddPassengerToBookings < ActiveRecord::Migration
  def change
    add_reference :bookings, :passenger, index: true, foreign_key: true
  end
end
