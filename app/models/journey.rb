class Journey < ActiveRecord::Base
  belongs_to :route
  has_many :stops, through: :route
  has_many :bookings, dependent: :destroy
  belongs_to :vehicle
  belongs_to :user

  scope :available, -> {where('start_time > ?', Time.now)}
end
