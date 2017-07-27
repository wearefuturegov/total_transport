class AddBookingToSuggestedJourney < ActiveRecord::Migration
  def change
    add_reference :suggested_journeys, :booking, index: true
  end
end
