class Journey < ActiveRecord::Base
  belongs_to :route
  has_many :stops, through: :route
  has_many :bookings, dependent: :destroy

  scope :available, -> {where('start_time > ?', Time.now)}
end
