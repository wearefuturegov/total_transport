class RemoveMissedFromBooking < ActiveRecord::Migration[4.2]
  def change
    remove_column :bookings, :missed, :boolean
  end
end
