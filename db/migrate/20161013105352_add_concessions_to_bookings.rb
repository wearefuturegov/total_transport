class AddConcessionsToBookings < ActiveRecord::Migration[4.2]
  def change
    add_column :bookings, :child_tickets, :integer, default: 0
    add_column :bookings, :older_bus_passes, :integer, default: 0
    add_column :bookings, :disabled_bus_passes, :integer, default: 0
    add_column :bookings, :scholar_bus_passes, :integer, default: 0
  end
end
