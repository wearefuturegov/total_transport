class PassengersController < ApplicationController
  skip_before_action :authenticate_passenger!, only: [:new, :create, :verify]

  def new
    @passenger = Passenger.new
  end

  def create
    if formatted_phone_number = Passenger.formatted_phone_number(params[:passenger][:phone_number])
      @passenger = Passenger.find_or_create_by(phone_number: formatted_phone_number)
      @passenger.send_verification!
      redirect_to verify_passenger_path(id: @passenger.id)
    else
      @passenger = Passenger.new
      flash[:alert] = "Phone number is not a valid phone number"
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
        flash[:alert] = "That verification code was incorrect. Please try again."
      end
    end
  end

  def show
    @page_title = "Edit Account"
    @back_path = routes_path
    @passenger = current_passenger
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
