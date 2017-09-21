module BookingsWorkflow
  class Edit
    include Rails.application.routes.url_helpers

    def initialize(step, route, booking)
      raise 'Invalid step key!' unless STEPS.include?(step)
      @step = step
      @step_with_action = "edit_#{step}".to_sym
      @route = route
      @booking = booking
    end
    
    def page_title
      {
        edit_return_journey: 'Pick Your Return Time',
        edit_requirements: 'Choose Your Requirements',
        edit_pickup_location: 'Choose Pick Up Point',
        edit_dropoff_location: 'Choose Drop Off Point',
        edit_verify: 'Verify your phone number',
        edit_confirm: 'Overview',
      }[@step_with_action]
    end
    
    def back_path
      index = STEPS.find_index(@step)
      if index.zero? || (index == 1 && @booking.return_journey_id.nil?)
        journeys_path
      else
        step = STEPS[index - 1]
        path = "edit_#{step}_route_booking_path".to_sym
        send(path, @route, @booking)
      end
    end

    def journeys
      if @step_with_action == :edit_return_journey
        params = {
          reversed: !@booking.reversed?,
          from_time: from_time
        }
      elsif [:edit_requirements, :edit_journey].include?(@step_with_action)
        params = {
          reversed: @booking.reversed?
        }
      else
        return nil
      end
      return @route.available_journeys_by_date(params)
    end
    
    def map_type
      {
        edit_pickup_location: 'pickup',
        edit_dropoff_location: 'dropoff'
      }[@step_with_action]
    end
    
    def template
      {
        edit_requirements: 'bookings/edit_requirements',
        edit_journey: 'bookings/edit_journey',
        edit_return_journey: 'bookings/edit_return_journey',
        edit_pickup_location: 'bookings/edit_pickup_dropoff_location',
        edit_dropoff_location: 'bookings/edit_pickup_dropoff_location',
        edit_verify: 'bookings/verify',
        edit_confirm: 'bookings/confirm'
      }[@step_with_action]
    end
    
    def allowed_vars
      vars = [:page_title, :back_path]
      case @step_with_action
      when :edit_requirements, :edit_journey, :edit_return_journey
        vars << :journeys
      when :edit_pickup_location, :edit_dropoff_location
        vars += [:stop, :map_type]
      end
      vars
    end
    
    def stop
      @booking.send("#{map_type}_stop")
    end
    
    private
    
      def from_time
        @booking.journey.time_at_stop(@booking.dropoff_stop)
      end
  end
end
