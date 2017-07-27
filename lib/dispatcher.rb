class Dispatcher
  
  def initialize(suggested_journey)
    @suggested_journey = suggested_journey
    @from = suggested_journey.start_time
    @booking = suggested_journey.booking
    @pickup_stop = @booking.pickup_stop
    @dropoff_stop = @booking.dropoff_stop
    @route = @suggested_journey.route
  end
  
  def perform!
    if suggested_journeys && possible_vehicles
      GeneratedJourney.create(
        route: @route,
        start_time: start_time,
        booking_ids: booking_ids_for_journeys(suggested_journeys),
        vehicles: possible_vehicles
      )
    end
  end
  
  private
  
    def possible_teams
      possible_vehicles.map { |v| v.team }.flatten.uniq
    end
    
    def possible_vehicles
      passengers = suggested_journeys.map { |j| j.booking.number_of_passengers }.sum
      Vehicle.where('seats >= ?', passengers).select { |v| potential_occupancy(passengers, v.seats) > 0.8 }
    end
  
    def booking_ids_for_journeys(journeys)
      journeys.map { |j| j.booking_id }
    end
  
    def potential_occupancy(seats, passengers)
      (seats.to_f / passengers.to_f)
    end
    
    def start_time
      sorted_journeys.first.start_time
    end
    
    def sorted_journeys
      suggested_journeys.sort_by { |j| j.booking.pickup_stop.position }
    end
    
    def suggested_journeys
      @suggested_journeys ||= SuggestedJourney.where(route: @route)
        .where('start_time BETWEEN ? AND ?', @from - 1.hour, @from + 1.hour)
        .select { |j| j.booking.reversed? == @suggested_journey.booking.reversed? }
    end
  
end
