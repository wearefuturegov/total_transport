class RemoveVehicles < ActiveRecord::Migration[4.2]
  def change
    Journey.all.each do |j|
      vehicle = ActiveRecord::Base.connection.execute("SELECT * FROM vehicles where id=#{j.vehicle_id}").first
      j.seats = vehicle['seats']
      j.save
    end
    drop_table :vehicles, force: :cascade
  end
end
