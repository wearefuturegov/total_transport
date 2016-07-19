class CreateBookings < ActiveRecord::Migration
  def change
    create_table :bookings do |t|
      t.references :journey, index: true, foreign_key: true
      t.references :pickup_stop, index: true
      t.float :pickup_lat
      t.float :pickup_lng
      t.references :dropoff_stop, index: true
      t.float :dropoff_lat
      t.float :dropoff_lng
      t.string :state

      t.timestamps null: false
    end
    add_foreign_key :bookings, :stops, column: :pickup_stop_id
    add_foreign_key :bookings, :stops, column: :dropoff_stop_id

  end
end
