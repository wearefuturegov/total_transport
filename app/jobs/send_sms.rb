class SendSMS < Que::Job
  
  def run(params)
    SmsService.new(params).perform
  end

end
