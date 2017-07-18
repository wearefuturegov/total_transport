class AddBookedToJourneys < ActiveRecord::Migration
  def change
    add_column :journeys, :booked, :boolean
    Booking.all.each do |b|
      if b.journey
        b.journey.booked = true
        b.journey.save
      end
    end
  end
end
