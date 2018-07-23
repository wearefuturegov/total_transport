class CreateTimetableTimes < ActiveRecord::Migration[4.2]
  def change
    create_table :timetable_times do |t|
      t.time :time
      t.references :timetable
    end
    
    remove_column :timetables, :times, :json, default: []
    add_reference :journeys, :timetable_time, index: true
    remove_reference :journeys, :timetable, index: true
  end
end
