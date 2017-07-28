class GeneratedJourney < ActiveRecord::Base
  belongs_to :route
  has_many :bookings
  has_and_belongs_to_many :vehicles
  has_many :teams, through: :vehicles
  
  
  def vehicles_by_team
    vehicles.group_by(&:team)
  end
  
  def vehicles_for_team(team)
    vehicles_by_team[team]
  end
  
  def reversed?
    bookings.first.reversed?
  end
end
