class AddTokenToBooking < ActiveRecord::Migration[4.2]
  def change
    add_column :bookings, :token, :string
  end
end
