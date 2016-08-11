class BookingsController < ApplicationController
  before_filter :find_route
  before_filter :find_booking, except: [:new, :create]

  # Choose stops
  def new
    @booking = current_passenger.bookings.new
    render template: 'bookings/choose_stops'
  end

  # Save stops
  def create
    @booking = current_passenger.bookings.create(booking_params)
    redirect_to choose_journey_route_booking_path(@route, @booking)
  end

  def choose_journey
  end

  def save_journey
    @booking.update_attributes(booking_params)
    redirect_to choose_pickup_location_route_booking_path(@route, @booking)
  end

  def choose_pickup_location
    @stop = @booking.pickup_stop
    @pickup_of_dropoff = 'pickup'
    render template: 'bookings/choose_pickup_dropoff_location'
  end

  def save_pickup_location
    @booking.update_attributes(booking_params)
    redirect_to choose_dropoff_location_route_booking_path(@route, @booking)
  end

  def choose_dropoff_location
    @stop = @booking.dropoff_stop
    @pickup_of_dropoff = 'dropoff'
    render template: 'bookings/choose_pickup_dropoff_location'
  end

  def save_dropoff_location
    @booking.update_attributes(booking_params)
    redirect_to confirm_route_booking_path(@route, @booking)
  end

  def destroy
    @booking.destroy
    redirect_to passenger_path
  end

  def suggest_journey
    if request.method == 'POST'
      @suggested_journey = SuggestedJourney.create!(suggested_journey_params)
      redirect_to choose_journey_route_booking_path(@route, @booking)
    else
      @suggested_journey = SuggestedJourney.new
    end
  end

  private

  def booking_params
    params.require(:booking).permit(:journey_id, :pickup_stop_id, :pickup_lat, :pickup_lng, :dropoff_stop_id, :dropoff_lat, :dropoff_lng, :state)
  end

  def suggested_journey_params
    params.require(:suggested_journey).permit(:start_time, :description).merge(route: @route, passenger: current_passenger)
  end

  def find_route
    @route = Route.find(params[:route_id])
  end

  def find_booking
    @booking = current_passenger.bookings.find(params[:id])
  end
end
