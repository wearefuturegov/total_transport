class PassengersController < ApplicationController
  skip_before_action :authenticate_passenger!
  def new

  end

  def create
    passenger = Passenger.find_or_create_by(phone_number: params[:passenger][:phone_number])
    passenger.send_verification!
    redirect_to verify_passenger_path(id: passenger.id)
  end

  def destroy
    logout_current_passenger
    redirect_to root_path
  end

  def verify
    @passenger = Passenger.find(params[:id])
    if request.method == 'POST'
      if @passenger.verification_code == params[:verification_code]
        set_current_passenger(@passenger)
        redirect_to root_path
      else
        @incorrect = true
      end
    end
  end
end
