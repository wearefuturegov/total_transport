class Timetable < ActiveRecord::Base
  belongs_to :route
  belongs_to :vehicle
  belongs_to :supplier

  has_many :journeys
  
  after_create :create_journeys
  
  private
  
    def create_journeys
      (from..to).each do |date|
        times.each do |t|
          t['journeys'] ||= []
          time = DateTime.parse(t['time']).strftime('%H:%M')
          start_time = DateTime.parse "#{date.to_s}T#{time}"
          t['journeys'] << create_journey(start_time).id
        end
      end
      save
    end
    
    def create_journey(start_time)
      journeys.create(journey_params.merge({start_time: start_time}))
    end
    
    def journey_params
      {
        vehicle: vehicle,
        supplier: supplier,
        route: route
      }
    end
end
