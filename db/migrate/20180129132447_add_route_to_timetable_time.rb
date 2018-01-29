class AddRouteToTimetableTime < ActiveRecord::Migration
  def change
    add_reference :timetable_times, :route, index: true
  end
end
