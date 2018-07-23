class AddPhoneNumberToBookings < ActiveRecord::Migration[4.2]
  def change
    add_column :bookings, :phone_number, :string
  end
end
