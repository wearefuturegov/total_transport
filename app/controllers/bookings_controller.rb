class BookingsController < ApplicationController
  before_filter :find_route, except: [:show]
  before_filter :find_booking, except: [:new, :create]
  include ApplicationHelper

  # Choose stops
  def new
    @page_title = "Choose Your Pick Up Area"
    @back_path = routes_path
    @top_sec = "Choose your pick up and drop off areas."
    @booking = current_passenger.bookings.new
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
    @booking = current_passenger.bookings.create(booking_params)
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
    redirect_to workflow.redirect_path
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

  def suggest_journey
    @page_title = "Suggest A New Time"
    @back_path = edit_journey_route_booking_path(@route, @booking)
    if request.method == 'POST'
      @suggested_journey = SuggestedJourney.create!(suggested_journey_params)
      redirect_to edit_journey_route_booking_path(@route, @booking)
    else
      @suggested_journey = SuggestedJourney.new
    end
  end

  def suggest_edit_to_stop
    @page_title = "Suggest A Stop Area Edit"
    @stop = Stop.find(params[:stop_id])
    if request.method == 'POST'
      @suggested_edit_to_stop = SuggestedEditToStop.create!(suggested_edit_to_stop_params)
      redirect_to edit_pickup_location_route_booking_path(@route, @booking)
    else
      @suggested_edit_to_stop = SuggestedEditToStop.new
    end
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
      :state,
      :phone_number,
      :passenger_name,
      :payment_method,
      :number_of_passengers,
      :special_requirements,
      :child_tickets,
      :older_bus_passes,
      :disabled_bus_passes,
      :scholar_bus_passes
    )
  end

  def suggested_journey_params
    params.require(:suggested_journey).permit(:start_time, :description).merge(route: @route, passenger: current_passenger)
  end

  def suggested_edit_to_stop_params
    params.require(:suggested_edit_to_stop).permit(:description).merge(stop: @stop, passenger: current_passenger)
  end

  def find_route
    @route = Route.find(params[:route_id])
  end

  def find_booking
    @booking = current_passenger.bookings.find(params[:id])
  end
end
