class Admin::SmsController < AdminController
  
  def new
  end
  
  def create
    if to = PhoneNumberFormatter.new(sms_params[:to]).format
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
