class SendEmail < Que::Job
  
  def run(mailer, method, args)
    begin
      mailer = Object.const_get(mailer)
      mailer.send(method, args)
    rescue ActiveRecord::RecordNotFound
      destroy
    end
  end

end
