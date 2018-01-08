class Admin::SmsController < AdminController
  
  def new
  end
  
  def create
    if to = Passenger.formatted_phone_number(sms_params[:to])
      SendSMS.enqueue(to: to, message: sms_params[:body])
      redirect_to admin_root_path
    else
      @flash_alert = "Phone number is not valid, please try another one"
      render action: 'new'
    end
  end
  
  private
  
    def sms_params
      params.require(:sms).permit(:to, :body)
    end
  
end
