class SendSMS < Que::Job
  
  def run(params)
    begin
      params[:booking] = Booking.find(params[:booking]) if params[:booking]
      params[:trip] = (params[:trip] == :outward_trip ? params[:booking].outward_trip : params[:booking].return_trip) if params[:trip]
      params[:passenger] = Passenger.find(params[:passenger]) if params[:passenger]
      SmsService.new(params).perform
    rescue ActiveRecord::RecordNotFound
      destroy
    end
  end

end
