class PaymentMethod < ActiveRecord::Base
  belongs_to :passenger
  has_many :bookings, dependent: :destroy

  def self.types
    [:paypal, :credit_card, :apple_pay, :google_pay, :cash, :balance]
  end

  def self.friendly_name_for_type(type)
    type.to_s.humanize
  end

  def friendly_name
    PaymentMethod.friendly_name_for_type(name)
  end
end
