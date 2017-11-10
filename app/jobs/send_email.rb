class SendEmail < Que::Job
  
  def run(mailer, method, args)
    begin
      mailer = Object.const_get(mailer)
      email = mailer.send(method, args)
      email.deliver_now!
    rescue ActiveRecord::RecordNotFound
      destroy
    end
  end

end
