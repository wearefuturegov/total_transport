class AddBookedToJourneys < ActiveRecord::Migration[4.2]
  def change
    add_column :journeys, :booked, :boolean, default: false
    Journey.all.each do |journey|
      journey.update_column(:booked, journey.bookings.count > 0)
    end
  end
end
