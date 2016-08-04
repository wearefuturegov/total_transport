class Passenger < ActiveRecord::Base
  def send_verification!
    set_verification_code
    @client = Twilio::REST::Client.new
    @client.messages.create(
      from: '+441173252034',
      to: self.phone_number,
      body: "Your verification code is #{self.verification_code}"
    )
  end

  def set_verification_code
    self.update_attribute(:verification_code, (rand * 10000).to_i)
  end
end
