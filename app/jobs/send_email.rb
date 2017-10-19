class SendEmail < Que::Job
  
  def run(klass, id)
    begin
      obj = Object.const_get(klass).find(id)
      BookingMailer.booking_confirmed(obj)
    rescue ActiveRecord::RecordNotFound
      destroy
    end
  end

end
