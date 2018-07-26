class BookingsController < PublicController
  before_action :find_booking, except: [:new, :create, :cancelled, :price, :passengers]
  skip_before_action :verify_authenticity_token, only: :send_missed_feedback
  include ApplicationHelper
  
  def new
    @from = Place.friendly.find(params[:from])
    @to = Place.friendly.find(params[:to])
    @journeys = get_journeys
    @booking = Booking.new
    @booking.passenger = Passenger.new
  end

  # Save stops
  def create
    @booking = Booking.create(booking_params)
    if @booking.valid?
      session[:booking_id] = @booking.id
      render :summary
    else
      render :edit
    end
  end
  
  def edit
    @from = @booking.pickup_stop.place
    @to = @booking.dropoff_stop.place
    @journeys = get_journeys
    @back_path = from_to_journeys_path(@booking.pickup_stop.place.slug, @booking.dropoff_stop.place.slug)
  end
  
  def update
    if params[:confirm]
      begin
        @booking.create_payment!(params[:stripe_token]) if params[:stripe_token].present?
        @booking.confirm!
        redirect_to confirmation_bookings_path
      rescue Stripe::CardError => e
        flash[:alert] = "There was a problem with your card. The message from the provider was: '#{e.message}'"
        render :summary
      end
    elsif booking_params[:cancellation_reason]
      @booking.update_attributes(booking_params)
      render :cancelled
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
    if booking_params[:pickup_stop_id].present? && booking_params[:dropoff_stop_id].present?
      @booking = Booking.new(booking_params)
    else
      head :ok
    end
  end
  
  def passengers
    @booking = Booking.new(booking_params)
  end
  
  def return_journeys
    start_time = DateTime.parse params[:start_time]
    @journeys = Journey.where(id: @booking.available_journeys(true)).where(start_time: start_time...start_time.end_of_day)
  end

  def destroy
    @booking.destroy
    redirect_to passenger_path
  end
  
  def cancel
    session[:booking_id] = @booking.id
    @page_title = "Cancel your booking"
  end
  
  def cancelled
  end
  
  def send_missed_feedback
    unless params[:booking][:token] == @booking.token
      head 401
    else
      @booking.update_attributes(booking_params.permit(:state, :missed_feedback))
      head :ok
    end
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
      :passenger_phone_number,
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
      :state,
      :missed_feedback,
      passenger_attributes: [:phone_number, :email, :name]
    )
  end

  def find_route
    @route = Route.find(params[:route_id])
  end

  def find_booking
    @booking = if params[:token]
      Booking.find_by_token(params[:token])
    elsif session[:booking_id]
      Booking.find(session[:booking_id])
    else
      Booking.find(params[:id])
    end
  end
  
  def get_journeys
    Journey.available_for_places(@from, @to)
           .where('start_time < ?', DateTime.now + 2.months)
           .order(:start_time)
           .group_by { |j| j.start_time.to_date }
  end
end
