class BookingsController < PublicController
  before_filter :authenticate_passenger!, only: [:show, :destroy]
  before_filter :find_route, except: [:show]
  before_filter :find_booking, except: [:new, :create]
  include ApplicationHelper

  # Choose stops
  def new
    @page_title = "Choose Your Pick Up Area"
    @back_path = routes_path
    @booking = Booking.new
    if params[:reversed] == 'true'
      @reversed = true
      @stops = @route.stops.reverse
    else
      @reversed = false
      @stops = @route.stops
    end
    render template: 'bookings/edit_stops'
  end

  # Save stops
  def create
    @booking = Booking.create(booking_params)
    redirect_to edit_requirements_route_booking_path(@route, @booking)
  end
  
  def edit
    workflow = BookingsWorkflow::Edit.new(params['step'].to_sym, @route, @booking)
    workflow.allowed_vars.each do |var|
      instance_variable_set("@#{var.to_s}", workflow.send(var))
    end
    render template: workflow.template
  end
  
  def update
    workflow = BookingsWorkflow::Save.new(params['step'].to_sym, @route, @booking, params[:booking])
    workflow.perform_actions!
    redirect_to workflow.redirect_path, alert: workflow.flash_alert
  end

  def confirmation
    @page_title = ""
    @back_path = routes_path
  end

  include ActionView::Helpers::NumberHelper
  def price_api
    @booking.set_promo_code(params[:booking][:promo_code])
    @booking.assign_attributes(booking_params)
    render json: {
      single: number_to_currency(@booking.single_price, unit: '£'),
      return: number_to_currency(@booking.return_price, unit: '£')
    }
  end

  def destroy
    @booking.destroy
    redirect_to passenger_path
  end

  def show
    @page_title = "Booking Details"
    @back_path = passenger_path
  end

  private

  def booking_params
    params.require(:booking).permit(
      :journey_id,
      :return_journey_id,
      :pickup_stop_id,
      :pickup_lat,
      :pickup_lng,
      :pickup_name,
      :dropoff_stop_id,
      :dropoff_lat,
      :dropoff_lng,
      :dropoff_name,
      :phone_number,
      :passenger_name,
      :payment_method,
      :number_of_passengers,
      :special_requirements,
      :child_tickets,
      :older_bus_passes,
      :disabled_bus_passes,
      :scholar_bus_passes,
      :single_journey,
      :verification_code
    )
  end

  def find_route
    @route = Route.find(params[:route_id])
  end

  def find_booking
    @booking = Booking.find(params[:id])
  end
end
