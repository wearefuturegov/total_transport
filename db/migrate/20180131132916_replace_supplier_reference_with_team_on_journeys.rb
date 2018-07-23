class ReplaceSupplierReferenceWithTeamOnJourneys < ActiveRecord::Migration[4.2]
  def change
    add_reference :journeys, :team
    Journey.all.each do |j|
      supplier = ActiveRecord::Base.connection.execute("SELECT * FROM suppliers where id=#{j.supplier_id}").first
      j.team_id = supplier['team_id']
      j.save
    end
    remove_column :journeys, :supplier_id
  end
end
