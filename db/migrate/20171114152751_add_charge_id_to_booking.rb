class AddChargeIdToBooking < ActiveRecord::Migration
  def change
    add_column :bookings, :charge_id, :string
  end
end
