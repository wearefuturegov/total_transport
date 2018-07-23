class AddPaymentMethodToBookings < ActiveRecord::Migration[4.2]
  def change
    add_reference :bookings, :payment_method, index: true, foreign_key: true
  end
end
