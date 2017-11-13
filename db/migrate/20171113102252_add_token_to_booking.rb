class AddTokenToBooking < ActiveRecord::Migration
  def change
    add_column :bookings, :token, :string
  end
end
