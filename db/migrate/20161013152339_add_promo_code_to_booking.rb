class AddPromoCodeToBooking < ActiveRecord::Migration
  def change
    add_reference :bookings, :promo_code, index: true, foreign_key: true
  end
end
