class AddClosedToBookingsToJourneys < ActiveRecord::Migration
  def change
    add_column :journeys, :open_to_bookings, :boolean, default: true
  end
end
