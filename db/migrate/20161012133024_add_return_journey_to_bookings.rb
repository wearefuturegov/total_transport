class AddReturnJourneyToBookings < ActiveRecord::Migration[4.2]
  def change
    add_column :bookings, :return_journey_id, :integer
  end
end
