class AddSeatsToJourney < ActiveRecord::Migration
  def change
    add_column :journeys, :seats, :integer, default: 0
  end
end
