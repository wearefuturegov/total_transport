class PassengersController < ApplicationController
  skip_before_action :authenticate_passenger!, only: [:new, :create, :verify]

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

  def show
    @page_title = "Edit Account"
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
