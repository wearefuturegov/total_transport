class SendSMS < Que::Job
  
  def run(params)
    params[:booking] = Booking.find(params[:booking]) if params[:booking]
    params[:passenger] = Passenger.find(params[:passenger]) if params[:passenger]
    SmsService.new(params).perform
  end

end
