class GeneratedJourney < ActiveRecord::Base
  belongs_to :route
  has_many :bookings
  has_and_belongs_to_many :vehicles
  has_many :teams, through: :vehicles
  
  after_create :send_notification!
  
  def vehicles_by_team
    vehicles.group_by(&:team)
  end
  
  def vehicles_for_team(team)
    vehicles_by_team[team]
  end
  
  def reversed?
    bookings.first.reversed?
  end
  
  private
  
    def send_notification!
      teams.uniq.each do |t|
        SupplierMailer.journey_email(t.suppliers, self, vehicles_for_team(t)).deliver_now
      end
    end
  
end
