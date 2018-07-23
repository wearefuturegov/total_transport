class AddRouteToTimetableTime < ActiveRecord::Migration[4.2]
  def change
    add_reference :timetable_times, :route, index: true
  end
end
