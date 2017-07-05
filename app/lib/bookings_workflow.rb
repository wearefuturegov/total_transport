class BookingsWorkflow
  include Rails.application.routes.url_helpers
    
  STEPS = [
    :choose_requirements,
    :choose_journey,
    :choose_return_journey,
    :choose_pickup_location,
    :choose_dropoff_location,
    :confirm
  ]
  
  def initialize(step, route, booking)
    raise 'Invalid step key!' unless STEPS.include?(step)
    @step = step
    @route = route
    @booking = booking
  end
  
  def page_title
    {
      choose_requirements: 'Choose Your Requirements',
      choose_journey: 'Choose Your Time Of Travel',
      choose_return_journey: 'Pick Your Return Time',
      choose_pickup_location: 'Choose Pick Up Point',
      choose_dropoff_location: 'Choose Drop Off Point',
      confirm: 'Overview',
    }[@step]
  end
  
  def back_path
    index = STEPS.find_index(@step)
    if index.zero?
      new_route_booking_path(@route)
    else
      route = STEPS[index - 1]
      path = "#{route}_route_booking_path".to_sym
      send(path, @route, @booking)
    end
  end
  
  def journeys
    if @step == :choose_return_journey
      params = {
        reversed: !@booking.reversed?,
        from_time: from_time
      }
    elsif [:choose_requirements, :choose_journey].include?(@step)
      params = {
        reversed: @booking.reversed?
      }
    else
      return nil
    end
    return @route.available_journeys_by_date(params)
  end
  
  def pickup_of_dropoff
    {
      choose_pickup_location: 'pickup',
      choose_dropoff_location: 'dropoff'
    }[@step]
  end
  
  def template
    {
      choose_requirements: 'bookings/choose_requirements',
      choose_journey: 'bookings/choose_journey',
      choose_return_journey: 'bookings/choose_return_journey',
      choose_pickup_location: 'bookings/choose_pickup_dropoff_location',
      choose_dropoff_location: 'bookings/choose_pickup_dropoff_location',
      confirm: 'bookings/confirm'
    }[@step]
  end
  
  def allowed_vars
    vars = [:page_title, :back_path]
    case @step
    when :choose_requirements, :choose_journey, :choose_return_journey
      vars << :journeys
    when :choose_pickup_location, :choose_dropoff_location
      vars += [:stop, :pickup_of_dropoff]
    end
    vars
  end
  
  def stop
    @booking.send("#{pickup_of_dropoff}_stop")
  end
  
  private
  
    def from_time
      @booking.dropoff_stop.time_for_journey(@booking.journey)
    end
end
