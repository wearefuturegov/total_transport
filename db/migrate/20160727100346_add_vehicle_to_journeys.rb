class AddVehicleToJourneys < ActiveRecord::Migration[4.2]
  def change
    add_reference :journeys, :vehicle, index: true, foreign_key: true
    add_reference :journeys, :user, index: true, foreign_key: true
  end
end
