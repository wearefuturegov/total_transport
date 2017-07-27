class CreateGeneratedJourneys < ActiveRecord::Migration
  def change
    create_table :generated_journeys do |t|
      t.references :route, index: true, foreign_key: true
      t.datetime :start_time
      t.references :bookings, index: true
      
      t.timestamps null: false
    end
    
    add_reference :bookings, :generated_journey, index: true
        
    create_table :generated_journeys_vehicles, id: false do |t|
      t.belongs_to :generated_journey, index: true
      t.belongs_to :vehicle, index: true
    end
  end
end
