class BookingsController < PublicController
  before_filter :find_booking, except: [:new, :create, :cancelled, :price]
  before_filter :get_passenger, :authenticate_passenger!, only: [:show, :destroy]
  #before_filter :find_route, except: [:show, :cancel, :cancelled, :new, :price]
  include ApplicationHelper
  
  def new
    @from = Place.friendly.find(params[:from])
    @to = Place.friendly.find(params[:to])
    @journeys = Journey.available_for_places(@from, @to).group_by { |j| j.start_time.to_date }
    @booking = Booking.new
  end

  # Save stops
  def create
    @booking = Booking.create(booking_params)
    if @booking.valid?
      render :summary
    else
      render :edit
    end
  end
  
  def edit
    @journeys = @booking.available_journeys.group_by { |j| j.start_time.to_date }
    @back_path = from_to_journeys_path(@booking.pickup_stop.place.slug, @booking.dropoff_stop.place.slug)
  end
  
  def update
    if params[:confirm]
      @booking.update_attribute :passenger, Passenger.setup(@booking.phone_number)
      begin
        @booking.create_payment!(params[:stripe_token]) if params[:stripe_token].present?
        @booking.confirm!
        redirect_to confirmation_route_booking_path(@route, @booking)
      rescue Stripe::CardError => e
        flash[:alert] = "There was a problem with your card. The message from the provider was: '#{e.message}'"
        render :summary
      end
    elsif booking_params[:cancellation_reason]
      @booking.update_attributes(booking_params)
      redirect_to :booking_cancelled
    else
      @booking.update_attributes(booking_params)
      if @booking.valid?
        render :summary
      else
        render :edit
      end
    end
  end

  def confirmation
    @page_title = ""
    @back_path = journeys_path
  end

  def price
    @booking.assign_attributes(booking_params)
  end
  
  def return_journeys
    start_time = DateTime.parse params[:start_time]
    @journeys = Journey.where(id: @booking.available_journeys(true)).where(start_time: start_time...start_time.end_of_day)
  end

  def destroy
    @booking.destroy
    redirect_to passenger_path
  end

  def show
    @page_title = "Booking Details"
    @back_path = passenger_path
  end
  
  def cancel
    @page_title = "Cancel your booking"
  end
  
  def cancelled
  end

  private

  def booking_params
    params.require(:booking).permit(
      :journey_id,
      :return_journey_id,
      :pickup_stop_id,
      :pickup_landmark_id,
      :dropoff_stop_id,
      :dropoff_landmark_id,
      :phone_number,
      :email,
      :passenger_name,
      :payment_method,
      :number_of_passengers,
      :special_requirements,
      :child_tickets,
      :older_bus_passes,
      :disabled_bus_passes,
      :scholar_bus_passes,
      :single_journey,
      :verification_code,
      :cancellation_reason,
      :state
    )
  end
  
  def get_passenger
    unless current_passenger
      passenger = Passenger.setup(@booking.passenger.phone_number)
      session[:return_to] = request.url
      redirect_to new_passenger_session_path(passenger.id)
    end
  end

  def find_route
    @route = Route.find(params[:route_id])
  end

  def find_booking
    @booking = if params[:token]
      Booking.find_by_token(params[:token])
    else
      Booking.find(params[:id])
    end
  end
end
