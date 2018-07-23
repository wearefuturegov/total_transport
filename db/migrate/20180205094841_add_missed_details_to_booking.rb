class AddMissedDetailsToBooking < ActiveRecord::Migration[4.2]
  def change
    add_column :bookings, :missed, :boolean, default: false
    add_column :bookings, :missed_feedback, :text
  end
end
