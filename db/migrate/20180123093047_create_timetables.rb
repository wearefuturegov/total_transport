class CreateTimetables < ActiveRecord::Migration
  def change
    create_table :timetables do |t|
      t.date :from
      t.date :to
      t.references :route
      t.references :vehicle
      t.references :supplier
      t.string :direction
      t.json :days, default: []
      t.json :times, default: []
      
      t.timestamps null: false
    end
    
    add_reference :journeys, :timetable, index: true
  end
end
