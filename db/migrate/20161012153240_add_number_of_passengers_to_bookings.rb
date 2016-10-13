class AddNumberOfPassengersToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :number_of_passengers, :integer, default: 1
  end
end
