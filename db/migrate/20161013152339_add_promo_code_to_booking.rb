class AddPromoCodeToBooking < ActiveRecord::Migration[4.2]
  def change
    add_reference :bookings, :promo_code, index: true, foreign_key: true
  end
end
