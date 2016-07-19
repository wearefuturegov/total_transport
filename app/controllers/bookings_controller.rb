class BookingsController < ApplicationController
  include Wicked::Wizard

  steps :choose_stops, :choose_journey, :choose_pickup_location, :choose_dropoff_location, :confirmation

  before_filter :find_route

  def show
    @booking = Booking.find(params[:booking_id])
    render_wizard
  end

  def update
    @booking = Booking.find(params[:booking_id])
    params[:booking][:state] = step.to_s
    @booking.update_attributes(params[:booking])
    render_wizard @booking
  end

  def create
    @booking = Booking.create
    redirect_to wizard_path(steps.first, :booking_id => @booking.id)
  end
  private

  def booking_params
    params.require(:booking).permit(:journey_id, :pickup_stop_id, :pickup_lat, :pickup_lng, :dropoff_stop_id, :dropoff_lat, :dropoff_lng, :state)
  end

  def find_route
    @route = Route.find(params[:route_id])
  end
end
