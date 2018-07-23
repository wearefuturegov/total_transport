class AddChargeIdToBooking < ActiveRecord::Migration[4.2]
  def change
    add_column :bookings, :charge_id, :string
  end
end
