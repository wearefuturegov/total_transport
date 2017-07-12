class SendSMS < Que::Job
  
  def run(params)
    begin
      params[:booking] = Booking.find(params[:booking]) if params[:booking]
      params[:passenger] = Passenger.find(params[:passenger]) if params[:passenger]
      SmsService.new(params).perform
    rescue ActiveRecord::RecordNotFound
      destroy
    end
  end

end
