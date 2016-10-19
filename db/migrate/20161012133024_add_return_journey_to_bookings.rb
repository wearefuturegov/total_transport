class AddReturnJourneyToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :return_journey_id, :integer
  end
end
