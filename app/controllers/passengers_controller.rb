class PassengersController < PublicController
  skip_before_action :authenticate_passenger!, only: [:new, :create]

  def new
    @passenger = Passenger.new
  end

  def create
    if formatted_phone_number = Passenger.formatted_phone_number(params[:passenger][:phone_number])
      @passenger = Passenger.setup(formatted_phone_number)
      redirect_to new_passenger_session_path(@passenger.id)
    else
      @passenger = Passenger.new
      @flash_alert = "Phone number is not a valid, please try another one"
      render action: 'new'
    end
  end

  def show
    @page_title = "Edit Account"
    @back_path = journeys_path
    @passenger = current_passenger
    @future_bookings = @passenger.active_bookings
    @past_bookings = @passenger.past_bookings
  end

  def update
    @passenger = current_passenger
    @passenger.update_attributes(passenger_params)
    redirect_to passenger_path
  end

  private

  def passenger_params
    params.require(:passenger).permit(:photo, :name)
  end
end
