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
  
  def approve(supplier, vehicle, options = {})
    journey = supplier.journeys.create(
      route: route,
      vehicle: vehicle,
      start_time: (options[:start_time] || start_time),
      open_to_bookings: options[:open_to_bookings],
      reversed: reversed?,
      bookings: bookings
    )
    notify_passengers(bookings)
    destroy
    journey
  end
  
  private
  
    def send_notification!
      teams.uniq.each do |t|
        SupplierMailer.journey_email(t.suppliers, self, vehicles_for_team(t)).deliver_now
      end
    end
    
    def notify_passengers(bookings)
      bookings.each do |booking|
        SendSMS.enqueue(to: booking.phone_number, template: :generated_journey, booking: booking.id)
      end
    end
  
end
