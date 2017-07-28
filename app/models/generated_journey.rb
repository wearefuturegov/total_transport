class GeneratedJourney < ActiveRecord::Base
  belongs_to :route
  has_many :bookings
  has_and_belongs_to_many :vehicles
  has_many :teams, through: :vehicles
  
  def reversed?
    bookings.first.reversed?
  end
end
