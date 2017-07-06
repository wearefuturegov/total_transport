module BookingsWorkflow
  class Save
    include Rails.application.routes.url_helpers

    def initialize(step, route, booking, params)
      raise 'Invalid step key!' unless STEPS.include?(step)
      @step = step
      @step_with_action = "save_#{step}".to_sym
      @route = route
      @booking = booking
      @params = params
    end
    
    def perform_actions!
      @booking.set_promo_code(@params[:promo_code]) if @step == :requirements
      @booking.update_attributes(params)
      @booking.send_confirmation! if @step == :confirm
    end
    
    def redirect_path
      i = single_journey? ? 2 : 1
      if @step == STEPS.last
        confirmation_route_booking_path(@route, @booking)
      else
        index = STEPS.find_index(@step)
        step = STEPS[index + i]
        path = "edit_#{step}_route_booking_path".to_sym
        send(path, @route, @booking)
      end
    end
    
    def params
      @params.permit(permitted_params)
    end
    
    private
    
      def permitted_params
        case @step
        when :requirements
          [
            :number_of_passengers,
            :child_tickets,
            :older_bus_passes,
            :disabled_bus_passes,
            :scholar_bus_passes,
            :special_requirements
          ]
        when :journey, :return_journey
          [
            :journey_id
          ]
        when :pickup_location
          [
            :pickup_lat,
            :pickup_lng,
            :pickup_name
          ]
        when :dropoff_location
          [
            :dropoff_lat,
            :dropoff_lng,
            :dropoff_name
          ]
        when :confirm
          [
            :state,
            :passenger_name,
            :phone_number,
            :payment_method
          ]
        end
      end
      
      def single_journey?
        @params[:single_journey] && @step == :journey
      end
  end
end