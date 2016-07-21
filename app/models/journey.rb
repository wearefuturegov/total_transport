class Journey < ActiveRecord::Base
  belongs_to :route
  has_many :stops, through: :route

  scope :available, -> {where('start_time > ?', Time.now)}
end
