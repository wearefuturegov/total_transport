class AddDefaultsToTimetableDays < ActiveRecord::Migration[4.2]
  def change
    change_column_default :timetables, :days, [0,1,2,3,4,5,6]
  end
end
