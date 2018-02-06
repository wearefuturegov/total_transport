class AddSeatsToTimetableTimes < ActiveRecord::Migration
  def change
    add_column :timetable_times, :seats, :integer, default: 0
  end
end
