class AddClosedToBookingsToJourneys < ActiveRecord::Migration[4.2]
  def change
    add_column :journeys, :open_to_bookings, :boolean, default: true
  end
end
