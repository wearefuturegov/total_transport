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

  def destroy
    logout_current_passenger
    redirect_to root_path
  end

  def verify
    @back_path = new_passenger_path
    @passenger = Passenger.find(params[:id])
    if request.method == 'POST'
      if @passenger.verification_code == params[:verification_code]
        set_current_passenger(@passenger)
        redirect_to root_path
      else
        @flash_alert = "That verification code was incorrect. Please try again."
      end
    end
  end

  def show
    @page_title = "Edit Account"
    @back_path = routes_path
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
