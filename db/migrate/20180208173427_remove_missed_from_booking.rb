class RemoveMissedFromBooking < ActiveRecord::Migration
  def change
    remove_column :bookings, :missed, :boolean
  end
end
