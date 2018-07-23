class AddSeatsToTimetableTimes < ActiveRecord::Migration[4.2]
  def change
    add_column :timetable_times, :seats, :integer, default: 0
  end
end
