class AddNumberOfPassengersToBookings < ActiveRecord::Migration[4.2]
  def change
    add_column :bookings, :number_of_passengers, :integer, default: 1
  end
end
