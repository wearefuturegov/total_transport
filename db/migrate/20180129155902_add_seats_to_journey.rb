class AddSeatsToJourney < ActiveRecord::Migration[4.2]
  def change
    add_column :journeys, :seats, :integer, default: 0
  end
end
