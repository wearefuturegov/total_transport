class ReplaceSupplierReferenceWithTeamInTimetable < ActiveRecord::Migration[4.2]
  def change
    add_reference :timetables, :team
    Timetable.all.each do |t|
      supplier = ActiveRecord::Base.connection.execute("SELECT * FROM suppliers where id=#{t.supplier_id}").first
      t.team_id = supplier['team_id']
      t.save
    end
    remove_column :timetables, :supplier_id
  end
end
