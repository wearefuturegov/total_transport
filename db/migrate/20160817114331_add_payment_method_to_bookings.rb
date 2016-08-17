class AddPaymentMethodToBookings < ActiveRecord::Migration
  def change
    add_reference :bookings, :payment_method, index: true, foreign_key: true
  end
end
