class SessionsController < PublicController
  skip_before_action :authenticate_passenger!
  before_action :find_passenger
  
  def new
    @back_path = new_passenger_path
  end
  
  def create
    if @passenger.verification_code == params[:verification_code]
      set_current_passenger(@passenger)
      redirect_to root_path
    else
      @flash_alert = "That verification code was incorrect. Please try again."
      render :new
    end
  end
  
  private
  
    def find_passenger
      @passenger = Passenger.find(params[:passenger_id])
    end
  
end
